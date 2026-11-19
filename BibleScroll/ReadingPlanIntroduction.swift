import SwiftUI

struct ReadingPlanIntroduction: View {
    let back: () -> Void
    let next: () -> Void

    var body: some View {
        OnboardingVideoScreen(
            title: "Reading the whole Bible is not impossible.",
            subtitle: "Pick a reading plan and follow it, one day at a time.",
            videoResource: "onboarding-reading-plan",
            videoAspectRatio: 1170 / 2532,
            back: back, next: next)
    }
}
