import SwiftUI

struct AnnualOfferPaywall: View {
    let option: SubscriptionOption?
    let busy: Bool
    let discountPercent: Int?
    let regularPrice: String?
    let close: () -> Void
    let claim: () -> Void
    let restore: () -> Void
    let terms: () -> Void
    let privacy: () -> Void
    @ScaledMetric(relativeTo: .title2) private var headingSize = 25.0
    @ScaledMetric(relativeTo: .largeTitle) private var priceSize = 34.0

    var body: some View {
        GeometryReader { area in
            let width = min(area.size.width, 500)
            ScrollView {
                VStack(spacing: 0) {
                    header
                    VStack(spacing: 16) {
                        Rectangle().fill(AppStyle.soft)
                            .frame(width: max(1, width - 48), height: area.size.height < 740 ? 76 : 96)
                            .overlay { Image("PaywallSunrise").resizable().scaledToFill() }
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .accessibilityHidden(true)
                        VStack(spacing: 10) {
                            Label("A special gift before you go", systemImage: "gift")
                                .font(.caption.weight(.medium)).foregroundStyle(AppStyle.bronze)
                                .padding(.horizontal, 13).padding(.vertical, 8)
                                .background(AppStyle.soft, in: Capsule())
                            Text("Make this your year in the Word.")
                                .font(.system(size: headingSize, weight: .bold))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Your daily habit starts with one small yes.")
                                .font(.subheadline).foregroundStyle(.secondary)
                                .multilineTextAlignment(.center).lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        if let option {
                            annualCard(option)
                        } else {
                            Text("This offer isn’t available right now.")
                                .font(.subheadline).foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity).padding(24)
                                .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 25))
                        }
                    }
                    .padding(.horizontal, 24)
                    Spacer(minLength: 22)
                    footer
                }
                .frame(width: width)
                .frame(minHeight: area.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(AppStyle.ink)
        .background(AppStyle.canvas.ignoresSafeArea())
        .buttonStyle(.plain)
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack {
            Spacer()
            Button(action: close) {
                Image(systemName: "xmark").font(.system(size: 18, weight: .regular))
                    .frame(width: 44, height: 44)
                    .background(AppStyle.surface, in: Circle())
                    .overlay(Circle().stroke(AppStyle.border, lineWidth: 1))
                    .shadow(color: AppStyle.shadow, radius: 5, y: 3)
            }
            .accessibilityLabel("Back to subscription options")
        }
        .padding(.horizontal, 22).padding(.top, 4).padding(.bottom, 12)
    }

    private func annualCard(_ option: SubscriptionOption) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                Text(discountPercent.map { "SAVE \($0)%" } ?? "YOUR ANNUAL OFFER")
                    .tracking(1)
                Spacer(minLength: 8)
                Text("Special price")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.white.opacity(0.18), in: Capsule())
            }
            .font(.caption.weight(.bold)).foregroundStyle(.white)
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(AppStyle.button)

            VStack(spacing: 10) {
            Text("ANNUAL PLAN")
                .font(.system(.caption2, design: .rounded).weight(.semibold)).tracking(1.6)
                .foregroundStyle(AppStyle.bronze)
            if discountPercent != nil, let regularPrice {
                Text("\(regularPrice) / \(option.period)")
                    .font(.subheadline).strikethrough().foregroundStyle(.secondary)
            }
            (
                Text(option.price).font(.system(size: priceSize, weight: .bold, design: .rounded)) +
                Text(" / \(option.period)").font(.title3.weight(.semibold))
            )
            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            Text("Billed every \(option.period)")
                .font(.subheadline).foregroundStyle(.secondary)
            if let discountPercent {
                Label("\(discountPercent)% less than our standard annual plan", systemImage: "checkmark.seal.fill")
                    .font(.caption.weight(.medium)).foregroundStyle(AppStyle.bronze)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)
            }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24).padding(.horizontal, 14)
        }
        .frame(maxWidth: .infinity)
        .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 25))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(AppStyle.bronze.opacity(0.8), lineWidth: 1.5))
        .accessibilityElement(children: .combine)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Button(action: claim) {
                HStack {
                    if busy { ProgressView().tint(.white) }
                    Text("Claim my special price")
                }
                    .font(.body.weight(.semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(AppStyle.button, in: Capsule())
            }
            .disabled(option == nil || busy).opacity(option == nil ? 0.45 : 1)
            Text(option?.billing ?? "")
                .font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
                .lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { links }
                VStack(spacing: 0) { links }
            }
            .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24).padding(.bottom, 12)
    }

    @ViewBuilder private var links: some View {
        Button("Restore Purchases", action: restore).frame(minHeight: 44)
        Text("·").accessibilityHidden(true)
        Button("Terms of Use", action: terms).frame(minHeight: 44)
        Text("·").accessibilityHidden(true)
        Button("Privacy Policy", action: privacy).frame(minHeight: 44)
    }
}
