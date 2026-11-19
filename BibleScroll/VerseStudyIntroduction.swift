import SwiftUI

struct VerseStudyIntroduction: View {
    let back: () -> Void
    let next: () -> Void

    var body: some View {
        OnboardingVideoScreen(
            title: "Go deeper into every verse.",
            subtitle: "Explore the meaning, discover the context, and understand how Scripture speaks to your life.",
            videoResource: "onboarding-verse-study",
            videoAspectRatio: 1170 / 2532,
            back: back, next: next)
    }
}
