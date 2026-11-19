import SwiftUI

struct SettingsView: View {
    let library: BibleLibrary
    @AppStorage("onboarding.reconnect.completed") private var onboardingCompleted = false
    private let sections = ["Account", "General", "Contact and support", "Subscription", "Legal"]

    var body: some View {
        List {
            ForEach(sections, id: \.self) { title in
                NavigationLink {
                    if title == "Subscription" {
                        SubscriptionSettingsView()
                    } else {
                        AppStyle.canvas
                        .ignoresSafeArea()
                        .navigationTitle(title)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                } label: {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(AppStyle.ink)
                        .padding(.vertical, 10)
                }
                .listRowBackground(AppStyle.surface)
            }
            Button { onboardingCompleted = false } label: {
                Label("Replay onboarding", systemImage: "arrow.counterclockwise")
                    .font(.body).foregroundStyle(AppStyle.bronze)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .listRowBackground(AppStyle.surface)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppStyle.canvas)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .tint(AppStyle.bronze)
    }
}
