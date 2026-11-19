import SwiftUI

struct OnboardingView: View {
    let finish: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step = 0

    var body: some View {
        Group {
            if step == 5 {
                PaywallView(back: { navigate(to: 4) }, finish: finish)
            } else if step == 4 {
                VerseStudyIntroduction(back: { navigate(to: 3) }, next: { navigate(to: 5) })
            } else if step == 3 {
                ReadingPlanIntroduction(back: { navigate(to: 2) }, next: { navigate(to: 4) })
            } else if step == 2 {
                ScriptureMomentIntroduction(back: { navigate(to: 1) }, next: { navigate(to: 3) })
            } else if step == 1 {
                ScriptureIntroduction(back: { navigate(to: 0) }, next: { navigate(to: 2) })
            } else {
                ReconnectIntroduction { navigate(to: 1) }
            }
        }
        .background(AppStyle.canvas.ignoresSafeArea())
        .tint(AppStyle.bronze)
    }

    private func navigate(to next: Int) {
        withAnimation(.easeInOut(duration: reduceMotion ? 0 : 0.25)) { step = next }
    }
}

private struct ReconnectIntroduction: View {
    let next: () -> Void
    private let background = Color(red: 0.035, green: 0.045, blue: 0.075)

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 7) {
                        Capsule().fill(.white).frame(width: 22, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 14)
                    .accessibilityLabel("Introduction, step 1 of 6")

                    Image("OnboardingDistraction")
                        .resizable().scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: max(250, min(560, geometry.size.height * 0.62)))
                        .mask {
                            LinearGradient(stops: [.init(color: .clear, location: 0),
                                                   .init(color: .black, location: 0.08),
                                                   .init(color: .black, location: 0.83),
                                                   .init(color: .clear, location: 1)],
                                           startPoint: .top, endPoint: .bottom)
                        }
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("MAKE ROOM FOR GOD")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .tracking(2.5).foregroundStyle(Color.white.opacity(0.55))
                        Text("Social media addiction pulls you away from God")
                            .font(.system(.largeTitle, design: .serif).weight(.medium))
                            .foregroundStyle(.white)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 28).padding(.bottom, 18)
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button(action: next) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 21, weight: .medium))
                            .foregroundStyle(background)
                            .frame(width: 60, height: 60)
                            .background(.white, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Continue to Scripture introduction")
                }
                .padding(.horizontal, 28).padding(.top, 12).padding(.bottom, 18)
                .background(background)
            }
        }
        .background(background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

