import SwiftUI

/// Custom native paywall backed by RevenueCat packages and verified entitlements.
struct PaywallView: View {
    let back: () -> Void
    let finish: () -> Void
    @EnvironmentObject private var subscriptions: SubscriptionStore
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedID: String?
    @State private var secondStep = false
    @State private var information: Information?
    @ScaledMetric(relativeTo: .title2) private var headingSize = 26.0

    private var selected: SubscriptionOption? {
        subscriptions.options.first { $0.id == selectedID }
            ?? subscriptions.options.first { $0.package.packageType == .annual }
            ?? subscriptions.options.first
    }

    private enum Information: String, Identifiable {
        case restore = "Restore Purchases", terms = "Terms of Use", privacy = "Privacy Policy", purchase = "Subscriptions"
        var id: String { rawValue }
    }

    var body: some View {
        Group {
            if secondStep {
                AnnualOfferPaywall(option: subscriptions.secondAnnual, busy: subscriptions.busy,
                    discountPercent: subscriptions.rescueDiscountPercent,
                    regularPrice: subscriptions.rescueRegularAnnual?.price,
                    close: { secondStep = false }, claim: {
                        guard let option = subscriptions.secondAnnual else { return }
                        Task { if await subscriptions.purchase(option) { finish() } }
                    }, restore: restore, terms: { showLegal(.terms) },
                    privacy: { showLegal(.privacy) })
            } else {
                GeometryReader { area in
                    let width = min(area.size.width, 500)
                    ScrollView {
                        VStack(spacing: 12) {
                            introduction(width: width, compact: area.size.height < 740)
                            offerSelection.padding(.horizontal, 20)
                            PaywallReaderStories().padding(.horizontal, 20)
                            if dynamicTypeSize.isAccessibilitySize { checkoutFooter }
                        }
                        .padding(.bottom, 14)
                        .frame(width: width)
                        .frame(maxWidth: .infinity)
                    }
                    .scrollIndicators(.hidden)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if !dynamicTypeSize.isAccessibilitySize {
                            checkoutFooter.frame(width: width).frame(maxWidth: .infinity)
                                .background(AppStyle.surface)
                        }
                    }
                }
            }
        }
        .background(AppStyle.canvas.ignoresSafeArea())
        .foregroundStyle(AppStyle.ink)
        .tint(AppStyle.bronze)
        .preferredColorScheme(.light)
        .task {
            if subscriptions.hasPremium { finish(); return }
            if subscriptions.options.isEmpty { await subscriptions.load() }
        }
        .onChange(of: subscriptions.hasPremium) { _, active in if active { finish() } }
        .alert("Subscriptions", isPresented: Binding(
            get: { secondStep && subscriptions.message != nil },
            set: { if !$0 { subscriptions.message = nil } })) {
                Button("OK") { subscriptions.message = nil }
            } message: { Text(subscriptions.message ?? "") }
        .sheet(item: $information) { item in
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: item == .restore ? "arrow.clockwise" : "doc.text")
                        .font(.largeTitle).foregroundStyle(AppStyle.bronze)
                    Text((item == .restore || item == .purchase) ? "Purchases aren’t available right now. Please try again later." : "This page will be available before subscriptions launch.")
                        .multilineTextAlignment(.center).foregroundStyle(.secondary)
                }
                .padding(28).frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppStyle.canvas)
                .navigationTitle(item.rawValue).navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { information = nil } } }
            }
            .tint(AppStyle.bronze)
        }
    }

    private func introduction(width: CGFloat, compact: Bool) -> some View {
        VStack(spacing: 14) {
            Rectangle().fill(AppStyle.soft)
                .frame(width: max(1, width - 40), height: compact ? 72 : 88)
                .overlay { Image("PaywallSunrise").resizable().scaledToFill() }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .accessibilityHidden(true)
                .overlay(alignment: .topLeading) {
                    Button { secondStep = true } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.medium)).frame(width: 44, height: 44)
                            .background(AppStyle.surface.opacity(0.85), in: Circle())
                    }
                    .accessibilityLabel("View annual rescue offer")
                    .disabled(subscriptions.busy)
                    .padding(6)
                }
            VStack(spacing: 10) {
                Text("Make room for the Word.")
                    .font(.system(size: headingSize, weight: .semibold, design: .serif))
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                Text("Build a meaningful daily rhythm of Scripture and reflection.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                benefit("book", "Bible reading")
                benefit("calendar", "Daily reading plans")
                benefit("sparkles", "Verse explanations")
                benefit("bookmark", "Personal notes")
            }
        }
        .padding(.horizontal, 20).padding(.top, 8)
    }

    private func benefit(_ symbol: String, _ title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).font(.system(size: 15, weight: .regular))
                .foregroundStyle(AppStyle.bronze)
                .frame(width: 28, height: 28)
                .background(AppStyle.soft.opacity(0.8), in: Circle())
            Text(title).font(.caption.weight(.medium)).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(AppStyle.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppStyle.border, lineWidth: 1))
    }

    private var offerSelection: some View {
        VStack(spacing: 10) {
            if subscriptions.loading {
                ProgressView("Loading subscription options…").font(.caption).padding(16)
            }
            ForEach(subscriptions.options) { offer in
                Button { selectedID = offer.id } label: { offerRow(offer) }
                    .accessibilityLabel("\(offer.title), \(offer.trial.map { "\($0) free, then " } ?? "")\(offer.price) every \(offer.period)")
                    .accessibilityAddTraits(selected?.id == offer.id ? .isSelected : [])
                    .disabled(subscriptions.busy)
            }
            if let selected, selected.trial != nil { trialTimeline(selected) }
        }
        .buttonStyle(.plain)
    }

    private var checkoutFooter: some View {
        VStack(spacing: 0) {
            Rectangle().fill(AppStyle.border).frame(height: 1)
            VStack(spacing: 8) {
                if let message = subscriptions.message {
                    VStack(spacing: 4) {
                        Text(message).font(.caption).foregroundStyle(.red).multilineTextAlignment(.center)
                        if subscriptions.options.isEmpty {
                            Button("Try again") { Task { await subscriptions.load() } }.font(.caption.weight(.semibold)).frame(minHeight: 44)
                        }
                    }
                }
                Button {
                    guard let selected else { return }
                    Task { if await subscriptions.purchase(selected) { finish() } }
                } label: {
                    HStack {
                        if subscriptions.busy { ProgressView().tint(.white) }
                        Text(selected?.trial == nil ? "Continue" : "Start my free trial")
                    }
                        .font(.body.weight(.semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(AppStyle.selected, in: Capsule())
                }
                .padding(.top, 4)
                .disabled(selected == nil || subscriptions.busy || subscriptions.loading)
                .opacity(selected == nil ? 0.45 : 1)
                Text("From every dollar we give back to the kingdom")
                    .font(.system(.caption2, design: .serif).italic())
                    .foregroundStyle(AppStyle.bronze)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12).padding(.top, 2)
                Text(selected?.billing ?? "")
                    .font(.caption2).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 3)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) { legalLinks }
                    VStack(spacing: 0) { legalLinks }
                }
                .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 6)
        }
        .background(AppStyle.surface.opacity(0.98))
        .buttonStyle(.plain)
    }

    @ViewBuilder private var legalLinks: some View {
        Button("Restore Purchases", action: restore).frame(minHeight: 44)
        Text("·").accessibilityHidden(true)
        Button("Terms of Use") { showLegal(.terms) }.frame(minHeight: 44)
        Text("·").accessibilityHidden(true)
        Button("Privacy Policy") { showLegal(.privacy) }.frame(minHeight: 44)
    }

    private func offerRow(_ offer: SubscriptionOption) -> some View {
        VStack(spacing: 0) {
            if offer.product.subscriptionPeriod?.unit == .year {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text("MOST POPULAR")
                        .tracking(0.7)
                    Spacer(minLength: 0)
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppStyle.bronze)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppStyle.bronze.opacity(0.09))
            }
            HStack(spacing: 12) {
            Image(systemName: selected?.id == offer.id ? "checkmark.circle" : "circle")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(selected?.id == offer.id ? AppStyle.bronze : AppStyle.bronze.opacity(0.3))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(offer.title).font(.body.weight(.semibold))
                    if let trial = offer.trial {
                        Label("\(trial) free", systemImage: "gift")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppStyle.bronze)
                            .padding(.horizontal, 7).padding(.vertical, 4)
                            .background(AppStyle.bronze.opacity(0.09), in: Capsule())
                    }
                }
                Text(offer.trial == nil ? "Billed every \(offer.period)" : "Free trial, then billed every \(offer.period)")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 4) {
                Text(offer.price).font(.body.weight(.semibold)).monospacedDigit().fixedSize(horizontal: true, vertical: false)
                Text("per \(offer.period)").font(.caption2).foregroundStyle(.secondary)
            }
        }
            .padding(.horizontal, 14).padding(.vertical, 10).frame(minHeight: 68)
        }
        .background(selected?.id == offer.id ? AppStyle.soft.opacity(0.6) : AppStyle.surface,
                    in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(selected?.id == offer.id ? AppStyle.selected : AppStyle.border,
                                                         lineWidth: selected?.id == offer.id ? 2 : 1))
        .clipShape(RoundedRectangle(cornerRadius: 17))
        .contentShape(RoundedRectangle(cornerRadius: 17))
    }

    private func trialTimeline(_ option: SubscriptionOption) -> some View {
        HStack(alignment: .top, spacing: 12) {
            trialStep("Today", detail: "\(option.trial ?? "") free", icon: "gift")
            Image(systemName: "arrow.right")
                .font(.caption).foregroundStyle(AppStyle.bronze.opacity(0.5))
                .padding(.top, 8).accessibilityHidden(true)
            trialStep("After \(option.trial ?? "the trial")", detail: "\(option.price) / \(option.period)", icon: "calendar")
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(AppStyle.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(AppStyle.border, lineWidth: 1))
        .padding(.top, 2)
    }

    private func trialStep(_ title: String, detail: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).font(.subheadline).foregroundStyle(AppStyle.bronze)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(AppStyle.ink)
                Text(detail).font(.caption2).foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private func restore() {
        Task { if await subscriptions.restore() { finish() } }
    }

    private func showLegal(_ item: Information) {
        let url = item == .terms ? subscriptions.termsURL : subscriptions.privacyURL
        if let url, url.scheme == "https" { openURL(url) }
        else { information = item }
    }

}
