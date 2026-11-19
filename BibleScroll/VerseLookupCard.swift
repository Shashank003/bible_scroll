import SwiftUI

struct VerseLookupCard: View {
    let library: BibleLibrary
    let study: (Verse) -> Void
    let read: (String) -> Void
    @State private var bookIndex = 0
    @State private var chapter = 1
    @State private var number = 1

    private var book: BibleBook { library.books[bookIndex] }
    private var safeChapter: Int { min(chapter, book.chapters.count) }
    private var verseCount: Int { book.chapters[safeChapter - 1].count }
    private var reference: String { "\(book.id).\(safeChapter).\(min(number, verseCount))" }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Explore a verse", systemImage: "magnifyingglass")
                .font(.headline)
            Text("Choose a passage to read or understand more deeply.")
                .font(.caption).foregroundStyle(.secondary)
            VStack(spacing: 12) {
                Picker("Book", selection: $bookIndex) {
                    ForEach(library.books.indices, id: \.self) { index in
                        Text(library.books[index].name).tag(index)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(AppStyle.soft.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("CHAPTER").font(.caption2).foregroundStyle(.secondary)
                        Picker("Chapter", selection: $chapter) {
                            ForEach(1...book.chapters.count, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(AppStyle.soft.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("VERSE").font(.caption2).foregroundStyle(.secondary)
                        Picker("Verse", selection: $number) {
                            ForEach(1...verseCount, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(AppStyle.soft.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .pickerStyle(.menu)
            .onChange(of: bookIndex) { _, _ in chapter = 1; number = 1 }
            .onChange(of: chapter) { _, _ in number = 1 }
            Button {
                if let index = library.indexByID[reference] { study(library.verses[index]) }
            } label: {
                HStack {
                    Text("Study this verse")
                    Image(systemName: "arrow.up.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(AppStyle.button, in: Capsule())
            }
            Button("Open in The Bible") { read(reference) }
                .font(.caption.weight(.medium))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.plain)
        .homeCard()
    }
}
