import SwiftUI

struct ChapterPicker: View {
    let book: BibleBook
    let current: Verse
    @ObservedObject var progress: ReadingProgress
    let select: (BibleBook, Int) -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    private var tileBackground: Color { AppStyle.surface }

    private var completedCount: Int {
        progress.completedCount(bookID: book.id, chapterCount: book.chapters.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: typeSize.isAccessibilitySize ? 2 : 3), spacing: 14) {
                    ForEach(1...book.chapters.count, id: \.self) { chapter in
                        chapterTile(chapter)
                    }
                }

                Button {
                    progress.toggleBook(bookID: book.id, chapterCount: book.chapters.count)
                } label: {
                    Label(completedCount == book.chapters.count
                          ? "Read" : "Mark \(book.name) as read",
                          systemImage: completedCount == book.chapters.count ? "checkmark.circle.fill" : "circle")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(completedCount == book.chapters.count ? Color.primary : Color.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(tileBackground, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
                .accessibilityLabel(completedCount == book.chapters.count
                                    ? "Mark \(book.name) as unread" : "Mark \(book.name) as read")

                Text("\(completedCount) of \(book.chapters.count) chapters done")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(AppStyle.surface)
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func chapterTile(_ chapter: Int) -> some View {
        let selected = book.id == current.bookID && chapter == current.chapter
        let done = progress.isDone(bookID: book.id, chapter: chapter)
        return ZStack(alignment: .topTrailing) {
            Button { select(book, chapter) } label: {
                Text("\(chapter)")
                    .font(.system(.title2, design: .rounded).weight(.medium))
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(selected ? Color.white : AppStyle.ink)
                    .background(selected ? AppStyle.selected : tileBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppStyle.border, lineWidth: 1))
                    .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .accessibilityLabel("Read \(book.name), chapter \(chapter)")
            .accessibilityValue(done ? "Done" : "Not done")

            // A separate button, so marking done does not navigate or dismiss.
            Button { progress.toggleChapter(bookID: book.id, chapter: chapter) } label: {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(done ? Color.green : (selected ? Color.white.opacity(0.7) : Color.secondary.opacity(0.55)))
                    .frame(width: 48, height: 48)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Mark \(book.name) chapter \(chapter) as \(done ? "not done" : "done")")
        }
        .aspectRatio(1.05, contentMode: .fit)
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: done)
    }
}
