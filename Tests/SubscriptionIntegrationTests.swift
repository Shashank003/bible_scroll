import Foundation
import RevenueCat
@main struct Checks {
 @MainActor static func main() async throws {
  let free = TestStoreProductDiscount(identifier: "trial", price: 0, localizedPriceString: "€0.00", paymentMode: .freeTrial,
       subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .week), numberOfPeriods: 1, type: .introductory)
  func package(trial: TestStoreProductDiscount? = nil, type: PackageType = .annual, unit: SubscriptionPeriod.Unit = .year) -> Package {
   let product = TestStoreProduct(localizedTitle: "Premium", price: 69.99, currencyCode: "EUR", localizedPriceString: "69,99 €",
       productIdentifier: "premium.annual", productType: .autoRenewableSubscription, localizedDescription: "Premium access",
       subscriptionGroupIdentifier: "premium", subscriptionPeriod: SubscriptionPeriod(value: 1, unit: unit),
       introductoryDiscount: trial, locale: Locale(identifier: "fr_FR")).toStoreProduct()
   return Package(identifier: "annual", packageType: type, storeProduct: product, offeringIdentifier: "default", webCheckoutUrl: nil)
  }
  let eligible = SubscriptionOption.make(package: package(trial: free), trialEligible: true)
  precondition(eligible.trial == "7 days")
  precondition(eligible.price == "69,99 €")
  let weeklyInMonthlySlot = SubscriptionOption.make(package: package(type: .monthly, unit: .week), trialEligible: false)
  precondition(weeklyInMonthlySlot.title == "Weekly" && weeklyInMonthlySlot.period == "week")
  precondition(eligible.billing.contains("69,99 €"))
  precondition(!eligible.billing.contains("$79.99"))
  precondition(SubscriptionOption.make(package: package(trial: free), trialEligible: false).trial == nil)
  precondition(SubscriptionOption.make(package: package(), trialEligible: true).trial == nil)
  precondition(SubscriptionOption.periodText(SubscriptionPeriod(value: 3, unit: .month)) == "3 months")
  let suite = "SubscriptionChecks.\(UUID())"
  let defaults = UserDefaults(suiteName: suite)!
  defer { defaults.removePersistentDomain(forName: suite) }
  defaults.set(true, forKey: "subscriptions.debugBypass")
  let store = SubscriptionStore(defaults: defaults)
  precondition(defaults.object(forKey: "subscriptions.debugBypass") == nil)
  precondition(!store.configured && !store.grantsAccess)
  await store.load()
  precondition(store.options.isEmpty && !store.grantsAccess && store.bootstrapped)
  let restored = await store.restore()
  precondition(!restored && !store.hasPremium)
  precondition(!store.grantsAccess)
  print("Passed: real SDK test products, localized prices, eligible/ineligible trials, no-trial offers, missing-key fail-closed access, restore failure, and legacy bypass removal without unlocking access.")
 }
}
