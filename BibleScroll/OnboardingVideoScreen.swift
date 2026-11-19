import SwiftUI
import UIKit

/// Shared typography and a clear portrait-video slot for the two benefit screens.
struct OnboardingVideoScreen: View {
    let title: String
    let subtitle: String
    var videoResource: String? = nil
    var videoAspectRatio: CGFloat = 9 / 16
    let back: () -> Void
    let next: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: back) {
                    Image(systemName: "arrow.left").frame(width: 44, height: 44)
                }
                .accessibilityLabel("Previous screen")
                Spacer()
            }
            .foregroundStyle(AppStyle.ink).padding(.horizontal, 18)

            GeometryReader { area in
                let width = min(500, max(1, area.size.width - 56))
                let headingHeight = textHeight(title, style: .largeTitle, serif: true, width: width)
                let subtitleHeight = textHeight(subtitle, style: .body, serif: false, width: width)
                // 14 between text blocks, 24 before media, and 36 for top/bottom breathing room.
                let available = area.size.height - headingHeight - subtitleHeight - 74
                let videoHeight = min(560, max(220, available))

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 14) {
                            Text(title)
                                .font(.system(.largeTitle, design: .serif))
                                .foregroundStyle(AppStyle.ink)
                            Text(subtitle)
                                .font(.body).foregroundStyle(.secondary)
                        }
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: width)

                        Group {
                            if let videoResource, let url = Bundle.main.url(forResource: videoResource, withExtension: "mp4") {
                                OnboardingLoopingVideo(url: url)
                                    .clipShape(RoundedRectangle(cornerRadius: 26))
                            } else {
                                Color.clear
                            }
                        }
                            .frame(width: min(width, videoHeight * videoAspectRatio), height: videoHeight)
                            .accessibilityHidden(true)
                    }
                    .padding(.top, 24).padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }

            Button(action: next) {
                Text("Continue").font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .background(Color.black, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 30).padding(.top, 16).padding(.bottom, 26)
        }
        .background(AppStyle.canvas.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private func textHeight(_ text: String, style: UIFont.TextStyle, serif: Bool, width: CGFloat) -> CGFloat {
        let size = UITraitCollection(preferredContentSizeCategory: dynamicTypeSize.uiContentSizeCategory)
        let base = UIFont.preferredFont(forTextStyle: style, compatibleWith: size)
        let font = serif ? UIFont(descriptor: base.fontDescriptor.withDesign(.serif) ?? base.fontDescriptor,
                                 size: base.pointSize) : base
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font, .paragraphStyle: paragraph], context: nil)
        return ceil(bounds.height) + 4
    }
}

private extension DynamicTypeSize {
    var uiContentSizeCategory: UIContentSizeCategory {
        switch self {
        case .xSmall: return .extraSmall
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .xLarge: return .extraLarge
        case .xxLarge: return .extraExtraLarge
        case .xxxLarge: return .extraExtraExtraLarge
        case .accessibility1: return .accessibilityMedium
        case .accessibility2: return .accessibilityLarge
        case .accessibility3: return .accessibilityExtraLarge
        case .accessibility4: return .accessibilityExtraExtraLarge
        case .accessibility5: return .accessibilityExtraExtraExtraLarge
        @unknown default: return .large
        }
    }
}
