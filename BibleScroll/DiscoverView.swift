import SwiftUI

struct DiscoverView: View {
    let library: BibleLibrary
    @StateObject private var progress = DiscoverProgress()
    @State private var sheet: StudySheet?
    @State private var pageIndex = 0

    private var studies: [DiscoverStudy] {
        let catalog = Dictionary(uniqueKeysWithValues: DiscoverStudy.catalog.map { ($0.id, $0) })
        return progress.order.compactMap { catalog[$0] }.filter {
            library.indexByID[$0.verseID] != nil
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                let pages = studies
                if pages.isEmpty {
                    ContentUnavailableView("No studies available", systemImage: "book",
                        description: Text("New passages will appear here when available."))
                } else {
                    VersePager(count: pages.count,
                               index: Binding(get: { min(pageIndex, pages.count - 1) },
                                              set: { pageIndex = min(max(0, $0), pages.count - 1) }),
                               revision: library.translationID) { index in
                        let study = pages[index]
                        return Group {
                            if study.kind == .scripture {
                                card(study, verse: library.verses[library.indexByID[study.verseID]!])
                            } else {
                                reflectionOrFact(study)
                            }
                        }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .clipped()
                    }
                    .id(pages.map(\.id).joined(separator: ","))
                    .clipped()
                    .onChange(of: pages.map(\.id)) { _, _ in pageIndex = 0 }
                }
            }
            .background(AppStyle.backdrop)
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $sheet) { selected in
                switch selected {
                case .analysis(let verse): VerseAnalysisView(verse: verse, library: library)
                case .reading(let study): DiscoverReadingView(study: study, library: library)
                }
            }
        }
    }

    private func lookupVerse(_ id: String) -> Verse? {
        library.indexByID[id].map { library.verses[$0] }
    }

    private func card(_ study: DiscoverStudy, verse: Verse) -> some View {
        return GeometryReader { geometry in
            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Text(study.theme)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppStyle.bronze)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(AppStyle.soft.opacity(0.55), in: Capsule())
                    Text(verse.reference)
                        .font(.system(.largeTitle, design: .serif))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                    Text(library.translationID)
                        .font(.caption2.weight(.semibold)).tracking(2)
                        .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)

                Text(verse.text)
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(AppStyle.ink)
                    .lineSpacing(7)
                    .multilineTextAlignment(.center)
                    .lineLimit(geometry.size.height > 680 ? 8 : 6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)

                if geometry.size.height > 540 {
                    VStack(alignment: .leading, spacing: 7) {
                        sectionTitle("BIBLICAL MEANING")
                        Text(study.meaning)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(5).lineLimit(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }


                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(study.related, id: \.self) { reference in
                            if let related = lookupVerse(reference) {
                                Button { sheet = .analysis(related) } label: {
                                    Text(related.reference)
                                        .font(.caption)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(Capsule().stroke(AppStyle.border, lineWidth: 1))
                                }
                                .accessibilityLabel("Explore \(related.reference)")
                            }
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                Button { sheet = .analysis(verse) } label: {
                    HStack(spacing: 8) {
                        Text("Deep study")
                        Image(systemName: "arrow.up.right").font(.caption.weight(.medium))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(AppStyle.button, in: Capsule())
                }

                Text("Swipe up to explore")
                    .font(.caption2).foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(24)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 28))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(AppStyle.border, lineWidth: 1))
            .buttonStyle(.plain)
        }
    }

    private func reflectionOrFact(_ study: DiscoverStudy) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)
            Image(systemName: study.kind == .reflection ? "quote.opening" : "lightbulb")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(AppStyle.bronze)
                .frame(width: 62, height: 62)
                .background(AppStyle.soft.opacity(0.55), in: Circle())
            Text(study.kind == .reflection ? "REFLECTION" : "BIBLE FACT")
                .font(.caption.weight(.semibold)).tracking(2)
                .foregroundStyle(.secondary)
            Text(study.theme)
                .font(.system(.title2, design: .serif))
                .foregroundStyle(AppStyle.ink)
                .multilineTextAlignment(.center)
            Text(study.body)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(AppStyle.ink)
                .lineSpacing(7)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
            Text(study.attribution)
                .font(.caption).foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Button { sheet = .reading(study) } label: {
                Label(study.kind == .fact ? "Read the source" : "Reflect with Scripture", systemImage: "book")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(AppStyle.soft.opacity(0.6), in: Capsule())
            }
            Text("Swipe up to explore")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(26)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 28))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title).font(.caption.weight(.semibold)).tracking(1.2).foregroundStyle(.secondary)
    }

}

private enum StudySheet: Identifiable {
    case analysis(Verse)
    case reading(DiscoverStudy)
    var id: String {
        switch self {
        case .analysis(let verse): return "analysis.\(verse.id)"
        case .reading(let study): return study.id
        }
    }
}
