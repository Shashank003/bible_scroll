import Foundation
import Combine
import RevenueCat

struct SubscriptionOption: Identifiable {
    let package: Package
    let trial: String?
    var id: String { package.identifier }
    var product: StoreProduct { package.storeProduct }
    var price: String { product.localizedPriceString }
    var title: String {
        if let period = product.subscriptionPeriod, period.value == 1 {
            switch period.unit {
            case .year: return "Annual"
            case .week: return "Weekly"
            case .month: return "Monthly"
            default: break
            }
        }
        return product.localizedTitle
    }
    var period: String {
        guard let period = product.subscriptionPeriod else { return "one-time purchase" }
        return Self.periodText(period)
    }
    var billing: String {
        let renewal = "Renews automatically unless canceled at least 24 hours before the current period ends."
        if let trial { return "\(trial) free, then \(price) every \(period). \(renewal) Cancel before the trial ends to avoid the first charge." }
        return "\(price) billed every \(period). \(renewal)"
    }

    static func make(package: Package, trialEligible: Bool) -> SubscriptionOption {
        var trial: String?
        if trialEligible, let intro = package.storeProduct.introductoryDiscount, intro.paymentMode == .freeTrial {
            let period = intro.subscriptionPeriod
            switch period.unit {
            case .day: trial = "\(period.value) \(period.value == 1 ? "day" : "days")"
            case .week: trial = "\(period.value * 7) days"
            default: trial = "\(period.value) \(periodText(period).replacingOccurrences(of: "\(period.value) ", with: ""))"
            }
        }
        return SubscriptionOption(package: package, trial: trial)
    }
    static func periodText(_ period: SubscriptionPeriod) -> String {
        let unit: String
        switch period.unit {
        case .day: unit = "day"
        case .week: unit = "week"
        case .month: unit = "month"
        case .year: unit = "year"
        @unknown default: unit = "period"
        }
        return period.value == 1 ? unit : "\(period.value) \(unit)s"
    }
}

@MainActor
final class SubscriptionStore: NSObject, ObservableObject, PurchasesDelegate {
    @Published private(set) var options: [SubscriptionOption] = []
    @Published private(set) var secondAnnual: SubscriptionOption?
    @Published private(set) var hasPremium = false
    @Published private(set) var bootstrapped = false
    @Published private(set) var loading = false
    @Published private(set) var busy = false
    @Published var message: String?
    @Published private(set) var managementURL: URL?
    @Published private(set) var expiration: Date?
    @Published private(set) var currentProductID: String?
    @Published private(set) var willRenew = false
    @Published private(set) var isTrial = false
    @Published private(set) var currentProduct: StoreProduct?

    var currentPlanName: String {
        guard hasPremium else { return "No active subscription" }
        if let product = currentProduct { return product.localizedTitle }
        let available = options + [secondAnnual].compactMap { $0 }
        return available.first { $0.product.productIdentifier == currentProductID }?.title ?? "Stillword Premium"
    }

    let configured: Bool
    let entitlementID: String
    private let offeringID: String
    private let secondOfferingID: String
    private let secondPackageID: String
    let termsURL: URL?
    let privacyURL: URL?

    var grantsAccess: Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-dev-skip-paywall") { return true }
        #endif
        return hasPremium
    }

    var rescueRegularAnnual: SubscriptionOption? {
        options.first { $0.product.subscriptionPeriod?.unit == .year && $0.product.subscriptionPeriod?.value == 1 }
    }

    var rescueDiscountPercent: Int? {
        guard let regular = rescueRegularAnnual, let offer = secondAnnual,
              let currency = regular.product.currencyCode,
              currency == offer.product.currencyCode,
              regular.product.price > 0, offer.product.price > 0,
              offer.product.price < regular.product.price else { return nil }
        let fraction = NSDecimalNumber(decimal: offer.product.price / regular.product.price).doubleValue
        let percent = Int(((1 - fraction) * 100).rounded())
        return percent > 0 ? percent : nil
    }

    init(defaults: UserDefaults = .standard) {
        func setting(_ key: String, fallback: String = "") -> String {
            let value = (Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty || value.contains("$(") ? fallback : value
        }
        let key = setting("RevenueCatPublicAPIKey")
        entitlementID = setting("RevenueCatEntitlementID", fallback: "premium")
        offeringID = setting("RevenueCatOfferingID")
        secondOfferingID = setting("RevenueCatSecondOfferingID")
        secondPackageID = setting("RevenueCatSecondPackageID")
        termsURL = URL(string: setting("PaywallTermsURL"))
        privacyURL = URL(string: setting("PaywallPrivacyURL"))
        #if DEBUG
        configured = key.hasPrefix("appl_") || key.hasPrefix("test_")
        #else
        configured = key.hasPrefix("appl_")
        #endif
        super.init()
        defaults.removeObject(forKey: "subscriptions.debugBypass")
        if configured {
            if !Purchases.isConfigured { Purchases.configure(withAPIKey: key) }
            Purchases.shared.delegate = self
        } else {
            bootstrapped = true
        }
    }

    func load() async {
        guard configured else {
            message = "Subscriptions aren’t available right now. Please try again later."
            bootstrapped = true
            return
        }
        guard !loading else { return }
        loading = true
        defer { loading = false; bootstrapped = true }
        await refreshAccess()
        do {
            let offerings = try await Purchases.shared.offerings()
            let first = offeringID.isEmpty ? offerings.current : offerings.all[offeringID]
            guard let first else { throw SetupError.missingOffering }
            let secondOffering = secondOfferingID.isEmpty ? nil : offerings.all[secondOfferingID]
            let second = secondPackageID.isEmpty ? nil : secondOffering?.availablePackages.first {
                $0.identifier == secondPackageID && $0.storeProduct.subscriptionPeriod?.unit == .year
                    && $0.storeProduct.subscriptionPeriod?.value == 1
            }
            // Read the product's actual period: a weekly SKU can be placed in a monthly package slot.
            let weekly = first.availablePackages.first {
                $0.storeProduct.subscriptionPeriod?.unit == .week && $0.storeProduct.subscriptionPeriod?.value == 1
                    && $0.storeProduct.productIdentifier != second?.storeProduct.productIdentifier
            }
            let products = [first.annual, weekly].compactMap { $0 }.filter {
                $0.storeProduct.productIdentifier != second?.storeProduct.productIdentifier
            }
            let ids = (products + [second].compactMap { $0 }).map { $0.storeProduct.productIdentifier }
            let eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(productIdentifiers: ids)
            func option(_ package: Package) -> SubscriptionOption {
                SubscriptionOption.make(package: package,
                    trialEligible: eligibility[package.storeProduct.productIdentifier]?.status == .eligible)
            }
            options = products.filter { $0.storeProduct.subscriptionPeriod != nil }.map(option)
            secondAnnual = second.map(option)
            // This follow-up is a no-trial offer. Never hide an eligible free trial's terms.
            if secondAnnual?.trial != nil { secondAnnual = nil }
            message = options.isEmpty ? "Subscription options aren’t available right now. Please try again later." : nil
        } catch {
            options = []
            secondAnnual = nil
            message = "Subscriptions aren’t available right now. Please try again later."
        }
    }

    func refreshAccess() async {
        guard configured else { return }
        do {
            apply(try await Purchases.shared.customerInfo())
            if let id = currentProductID {
                let products = await Purchases.shared.products([id])
                if currentProductID == id { currentProduct = products.first }
            }
        }
        catch { /* Keep the last verified entitlement on a temporary connection failure. */ }
    }

    func purchase(_ option: SubscriptionOption) async -> Bool {
        guard configured, !busy else { return false }
        busy = true; message = nil
        defer { busy = false }
        do {
            let result = try await Purchases.shared.purchase(package: option.package)
            apply(result.customerInfo)
            if result.userCancelled { return false }
            if !hasPremium { message = "Your purchase hasn’t unlocked access yet. Please try Restore Purchases shortly." }
            return hasPremium
        } catch {
            if (error as NSError).code != ErrorCode.purchaseCancelledError.rawValue {
                message = "Your purchase couldn’t be completed. Please try again."
            }
            return false
        }
    }

    func restore() async -> Bool {
        guard configured, !busy else {
            if !configured { message = "Restore Purchases isn’t available right now. Please try again later." }
            return false
        }
        busy = true; message = nil
        defer { busy = false }
        do {
            apply(try await Purchases.shared.restorePurchases())
            if !hasPremium { message = "No active subscription was found for this Apple Account." }
            return hasPremium
        } catch {
            message = "Your purchases couldn’t be restored. Please try again."
            return false
        }
    }

    private func apply(_ info: CustomerInfo) {
        let entitlement = info.entitlements[entitlementID]
        hasPremium = entitlement?.isActive == true
        expiration = entitlement?.expirationDate
        managementURL = info.managementURL
        if currentProductID != entitlement?.productIdentifier { currentProduct = nil }
        currentProductID = entitlement?.productIdentifier
        willRenew = entitlement?.willRenew == true
        isTrial = entitlement?.periodType == .trial
    }

    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor [weak self] in self?.apply(customerInfo) }
    }

    private enum SetupError: Error { case missingOffering }
}
