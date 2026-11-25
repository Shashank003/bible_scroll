import SwiftUI

@main
struct BibleScrollApp: App {
    var body: some Scene {
        WindowGroup {
            AppEntryView()
        }
    }
}

private struct AppEntryView: View {
    @StateObject private var subscriptions = SubscriptionStore()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboarding.reconnect.completed") private var completed = false
    @State private var launching = true
    @AppStorage("app.theme") private var theme = "system"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if launching || (completed && !subscriptions.bootstrapped) {
                AppLoadingView()
            } else if completed {
                if subscriptions.grantsAccess {
                    AppTabs()
                } else {
                    PaywallView(back: { completed = false }, finish: { completed = true })
                }
            } else {
                OnboardingView { completed = true }
            }
        }
        .environmentObject(subscriptions)
        .preferredColorScheme(theme == "light" ? .light : theme == "dark" ? .dark : nil)
        .task { await subscriptions.load() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await subscriptions.refreshAccess() } }
        }
        .task {
            guard launching else { return }
            do { try await Task.sleep(for: .milliseconds(650)) }
            catch { return }
            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.25)) { launching = false }
        }
    }
}

private struct AppLoadingView: View {
    var body: some View {
        VStack(spacing: 28) {
            Image("AppLogo").resizable().scaledToFit().frame(width: 96, height: 96)
                .accessibilityHidden(true)
            ProgressView().controlSize(.small).tint(AppStyle.bronze)
                .accessibilityLabel("Opening your Bible")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppStyle.canvas.ignoresSafeArea())
    }
}
