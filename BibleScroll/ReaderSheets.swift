import SwiftUI

struct BookPicker: View {
    let books: [BibleBook]
    let current: Verse
    @ObservedObject var progress: ReadingProgress
    let select: (BibleBook, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    var body: some View {
        NavigationStack {
            List {
                testament("Old Testament", books: Array(books.prefix(39)))
                testament("New Testament", books: Array(books.dropFirst(39)))
            }
            .scrollContentBackground(.hidden)
            .background(AppStyle.canvas)
            .searchable(text: $search, prompt: "Search books")
            .navigationTitle("Select Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func testament(_ title: String, books: [BibleBook]) -> some View {
        let filtered = books.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
        if !filtered.isEmpty {
            Section(title) {
                ForEach(filtered) { book in
                    NavigationLink {
                        ChapterPicker(book: book, current: current, progress: progress, select: select)
                    } label: {
                        HStack {
                            Text(book.name)
                            Spacer()
                            let done = progress.completedCount(bookID: book.id, chapterCount: book.chapters.count)
                            if done == book.chapters.count {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            }
                            Text(done == 0 ? "\(book.chapters.count) chapters" : "\(done)/\(book.chapters.count) done")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

struct TranslationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bible.translation") private var selected = "KJV"
    private let translations = [("KJV", "King James Version"), ("WEB", "World English Bible")]

    var body: some View {
        NavigationStack {
            List {
                ForEach(translations, id: \.0) { translation in
                    Button {
                        selected = translation.0
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(translation.0).font(.headline).foregroundStyle(AppStyle.ink)
                                Text(translation.1).foregroundStyle(.secondary)
                                Label("Offline · Old and New Testaments", systemImage: "checkmark.circle.fill")
                                    .font(.caption).foregroundStyle(.green)
                            }
                            Spacer()
                            if selected == translation.0 { Image(systemName: "checkmark").foregroundStyle(AppStyle.bronze) }
                        }
                        .padding(.vertical, 8)
                    }
                }
                Section("Text sources") {
                    Text("Both complete translations are stored on your iPhone. Notes, likes, bookmarks, and chapter progress are shared across versions.")
                    Link("WEB · Public domain and source", destination: URL(string: "https://ebible.org/engwebp/copyright.htm")!)
                    Link("KJV · Source information", destination: URL(string: "https://ebible.org/eng-kjv2006/copr.htm")!)
                    Text("KJV is public domain outside the United Kingdom. Special publication rights apply in the United Kingdom.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppStyle.canvas)
            .navigationTitle("Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

struct ReadingSettings: View {
    @Binding var fontSize: Double
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("Text size") {
                    Slider(value: $fontSize, in: 22...42, step: 1)
                        .accessibilityLabel("Verse text size")
                        .accessibilityValue("\(Int(fontSize)) points")
                    Text("In the beginning was the Word.")
                        .font(.system(size: fontSize, design: .serif))
                }
                Section {
                    Text("Appearance follows your iPhone’s light or dark mode. Swipe up for the next verse. For long verses, swipe left for the next part and right for the previous part, or use the arrow buttons.")
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppStyle.canvas)
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
    }
}
