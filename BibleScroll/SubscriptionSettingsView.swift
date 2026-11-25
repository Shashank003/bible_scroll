import SwiftUI

struct SubscriptionSettingsView: View {
    @EnvironmentObject private var subscriptions: SubscriptionStore
    @State private var showPaywall = false

    var body: some View {
        List {
            Section("Current plan") {
                Label(subscriptions.hasPremium ? "Premium is active" : "No active subscription",
                      systemImage: subscriptions.hasPremium ? "checkmark.seal.fill" : "sparkles")
                    .foregroundStyle(subscriptions.hasPremium ? Color.green : AppStyle.ink)
                if subscriptions.hasPremium {
                    Text(subscriptions.currentPlanName).font(.headline)
                    if subscriptions.isTrial {
                        Text("Free trial").font(.subheadline).foregroundStyle(AppStyle.bronze)
                    }
                    if let product = subscriptions.currentProduct, let period = product.subscriptionPeriod {
                        Text("\(product.localizedPriceString) per \(SubscriptionOption.periodText(period))")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                if let expiration = subscriptions.expiration {
                    Text("\(subscriptions.hasPremium && subscriptions.willRenew ? "Renews" : "Access ends") \(expiration.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .listRowBackground(AppStyle.surface)
            Section {
                Button("View subscription options") { showPaywall = true }
                Button {
                    Task { _ = await subscriptions.restore() }
                } label: {
                    HStack {
                        Text("Restore Purchases")
                        Spacer()
                        if subscriptions.busy { ProgressView() }
                    }
                }
                .disabled(subscriptions.busy)
                Link("Cancel my subscription", destination: subscriptions.managementURL ?? URL(string: "https://apps.apple.com/account/subscriptions")!)
                Text("Cancellation is completed in Apple’s subscription settings. Deleting the app does not cancel your subscription.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .listRowBackground(AppStyle.surface)
        }
        .scrollContentBackground(.hidden).background(AppStyle.canvas)
        .navigationTitle("Subscription").navigationBarTitleDisplayMode(.inline)
        .tint(AppStyle.bronze)
        .task { await subscriptions.refreshAccess() }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(back: { showPaywall = false }, finish: { showPaywall = false })
        }
        .alert("Subscriptions", isPresented: Binding(get: { subscriptions.message != nil && !showPaywall },
                                                     set: { if !$0 { subscriptions.message = nil } })) {
            Button("OK") { subscriptions.message = nil }
        } message: { Text(subscriptions.message ?? "") }
    }
}
