import SwiftUI

struct ScriptureMomentIntroduction: View {
    let back: () -> Void
    let next: () -> Void

    var body: some View {
        OnboardingVideoScreen(
            title: "Every scroll feeds your soul.",
            subtitle: "One verse at a time. A moment to draw closer to God.",
            videoResource: "onboarding-scripture",
            videoAspectRatio: 1170 / 2532,
            back: back, next: next)
    }
}
