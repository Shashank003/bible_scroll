import SwiftUI

struct ScriptureIntroduction: View {
    let back: () -> Void
    let next: () -> Void
    private let background = Color(red: 0.035, green: 0.045, blue: 0.075)

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: back) {
                            Image(systemName: "arrow.left").frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Previous screen")
                        Spacer()
                    }
                    HStack(spacing: 7) {
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Capsule().fill(.white).frame(width: 22, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                        Circle().fill(.white.opacity(0.25)).frame(width: 5, height: 5)
                    }
                    .accessibilityLabel("Introduction, step 2 of 6")
                }
                .foregroundStyle(.white).padding(.horizontal, 20).padding(.top, 4)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("A DIFFERENT KIND OF SCROLL")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .tracking(2.5).foregroundStyle(.white.opacity(0.55))
                            Text("Turn scrolling\ninto Scripture.")
                                .font(.system(.largeTitle, design: .serif).weight(.medium))
                                .foregroundStyle(.white).lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("One swipe. One verse. A moment to draw closer to God.")
                                .font(.subheadline).foregroundStyle(.white.opacity(0.65)).lineSpacing(5)
                        }
                    }
                    .padding(.horizontal, 28).padding(.bottom, 24)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity, minHeight: max(0, geometry.size.height - 150), alignment: .center)
                }
                HStack {
                    Spacer()
                    Button(action: next) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 21, weight: .medium))
                            .foregroundStyle(background).frame(width: 60, height: 60)
                            .background(.white, in: Circle())
                    }
                    .buttonStyle(.plain).accessibilityLabel("Continue onboarding")
                }
                .padding(.horizontal, 28).padding(.vertical, 18)
            }
        }
        .background(background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

}
