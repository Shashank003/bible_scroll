import SwiftUI

struct SubscriptionSettingsView: View {
    @EnvironmentObject private var subscriptions: SubscriptionStore
    @State private var showPaywall = false

    var body: some View {
        List {
            Section("Your access") {
                Label(subscriptions.hasPremium ? "Premium is active" : "No active subscription",
                      systemImage: subscriptions.hasPremium ? "checkmark.seal.fill" : "sparkles")
                    .foregroundStyle(subscriptions.hasPremium ? Color.green : AppStyle.ink)
                if let expiration = subscriptions.expiration {
                    Text("Current access through \(expiration.formatted(date: .abbreviated, time: .omitted))")
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
                Link("Manage subscription", destination: subscriptions.managementURL ?? URL(string: "https://apps.apple.com/account/subscriptions")!)
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
