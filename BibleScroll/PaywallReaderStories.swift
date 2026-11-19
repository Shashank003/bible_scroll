import SwiftUI

private struct ReaderReview: Identifiable, Decodable {
    let id: String
    let displayName: String
    let quote: String
    let isPublished: Bool

    // Bundled content is editable without changing layout code. Replace lorem ipsum before release.
    static let published: [ReaderReview] = {
        guard let url = Bundle.main.url(forResource: "reader-reviews", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let reviews = try? JSONDecoder().decode([ReaderReview].self, from: data) else { return [] }
        var seen = Set<String>()
        return reviews.filter {
            $0.isPublished && !$0.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !$0.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && seen.insert($0.id).inserted
        }
    }()
}

struct PaywallReaderStories: View {
    var body: some View {
        if !ReaderReview.published.isEmpty {
            LazyVStack(alignment: .leading, spacing: 14) {
                Text("What people are saying")
                    .font(.system(.title2, design: .serif).weight(.semibold))
                    .foregroundStyle(AppStyle.ink)
                    .padding(.bottom, 3)

                ForEach(ReaderReview.published) { review in
                    VStack(alignment: .leading, spacing: 16) {
                        Text("“\(review.quote)”")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(AppStyle.ink)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 10) {
                            Text(String(review.displayName.prefix(1)).uppercased())
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppStyle.bronze)
                                .frame(width: 30, height: 30)
                                .background(AppStyle.soft, in: Circle())
                                .accessibilityHidden(true)
                            Text(review.displayName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppStyle.bronze)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 22))
                    .shadow(color: AppStyle.shadow, radius: 10, y: 4)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}
