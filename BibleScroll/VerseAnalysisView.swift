import SwiftUI

struct VerseAnalysisView: View {
    let verse: Verse
    let library: BibleLibrary
    @Environment(\.dismiss) private var dismiss
    @State private var expanded = "Explain easier"
    @State private var analysis: GeminiAnalysis?
    @State private var loading = true
    @State private var unavailable = false
    @State private var attempt = 0

    private var context: [Verse] {
        guard let index = library.indexByID[verse.id] else { return [] }
        return Array(library.verses[max(0, index - 2)...min(library.verses.count - 1, index + 2)])
            .filter { $0.bookID == verse.bookID && $0.chapter == verse.chapter }
    }

    private var relatedText: String {
        var seen = Set<String>()
        return (analysis?.relatedVerseIDs ?? []).filter { seen.insert($0).inserted }.compactMap { id in
            library.indexByID[id].map { index in
                let passage = library.verses[index]
                return "\(passage.reference)\n\(passage.text)"
            }
        }.joined(separator: "\n\n")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 14) {
                        Label("VERSE ANALYSIS", systemImage: "sparkles")
                            .font(.caption.weight(.semibold)).tracking(2)
                            .foregroundStyle(.secondary)
                        Text(verse.reference)
                            .font(.system(.largeTitle, design: .serif))
                            .multilineTextAlignment(.center)
                        Text(library.translationID)
                            .font(.caption).foregroundStyle(.secondary)
                        Text(verse.text)
                            .font(.system(.title3, design: .serif))
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .textSelection(.enabled)
                            .padding(22)
                            .frame(maxWidth: .infinity)
                            .background(AppStyle.paper,
                                        in: RoundedRectangle(cornerRadius: 24))
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Go beneath the words")
                            .font(.system(.title2, design: .serif))
                        Text("Read carefully, consider the context, and reflect.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }

                    if loading {
                        HStack(spacing: 14) {
                            ProgressView().tint(AppStyle.bronze)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("A closer look at Scripture").font(.subheadline.weight(.medium))
                                Text("Preparing your explanation…").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(22)
                        .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 22))
                    } else if unavailable {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("AI features aren’t available right now.", systemImage: "sparkles")
                                .font(.subheadline.weight(.medium)).foregroundStyle(.red)
                            Button("Try again") { attempt += 1 }
                                .font(.caption.weight(.semibold)).foregroundStyle(.red)
                                .frame(minHeight: 44)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(18)
                        .background(Color.red.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.12)))
                    } else if let analysis {
                        VStack(spacing: 12) {
                            analysisSection("Explain easier", icon: "lightbulb", color: AppStyle.bronze,
                                            subtitle: "The passage in simple words", description: analysis.explanation)
                            analysisSection("Deeper study", icon: "book.pages", color: AppStyle.bronze,
                                            subtitle: "Meaning and context", description: analysis.deeperStudy)
                            analysisSection("Historical context", icon: "clock", color: AppStyle.bronze,
                                            subtitle: "The world behind the words", description: analysis.historicalContext)
                            analysisSection("Original language", icon: "character.book.closed", color: AppStyle.bronze,
                                            subtitle: "A closer look at the wording", description: analysis.originalLanguage)
                            analysisSection("Apply it", icon: "leaf", color: .green,
                                            subtitle: "A response for your day", description: analysis.application)
                            if !relatedText.isEmpty {
                                analysisSection("Related verses", icon: "link", color: AppStyle.bronze,
                                                subtitle: library.translationID, description: relatedText)
                            }
                        }
                        Text("AI-generated explanation · Read alongside Scripture and check important details.")
                            .font(.caption2).foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Label("READ IN CONTEXT", systemImage: "text.alignleft")
                            .font(.caption.weight(.semibold)).tracking(1.5)
                            .foregroundStyle(.secondary)
                        ForEach(context) { passage in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(passage.reference)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Text(passage.text)
                                    .font(.system(.body, design: .serif))
                                    .lineSpacing(5)
                                    .textSelection(.enabled)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(passage.id == verse.id ? Color.primary.opacity(0.06) : .clear,
                                        in: RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    ShareLink(item: "\(verse.text)\n— \(verse.reference) (\(library.translationID))") {
                        Label("Share verse", systemImage: "square.and.arrow.up")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(AppStyle.surface, in: Capsule())
                    }
                }
                .padding(22)
            }
            .background(AppStyle.backdrop)
            .navigationTitle("Verse analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(AppStyle.bronze)
        .presentationDragIndicator(.visible)
        .task(id: "\(library.translationID):\(verse.id):\(attempt)") { await loadAnalysis() }
    }

    @MainActor
    private func loadAnalysis() async {
        loading = true
        unavailable = false
        analysis = nil
        do {
            let result = try await GeminiAnalysisService.shared.generate(
                verse: verse, translation: library.translationID, context: context)
            try Task.checkCancellation()
            analysis = result
            loading = false
        } catch {
            guard !Task.isCancelled else { return }
            loading = false
            unavailable = true
        }
    }

    private func analysisSection(_ title: String, icon: String, color: Color,
                                 subtitle: String, description: String) -> some View {
        DisclosureGroup(isExpanded: Binding(get: { expanded == title }, set: { expanded = $0 ? title : "" })) {
            Text(description)
                .font(.system(.body, design: .serif))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppStyle.border, lineWidth: 1))
    }
}
