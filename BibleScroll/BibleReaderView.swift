import SwiftUI
import UIKit

struct BibleReaderView: View {
    let library: BibleLibrary
    @Binding var requestedVerseID: String?

    var body: some View {
        ReaderContent(library: library, requestedVerseID: $requestedVerseID)
    }

}

private struct ReaderContent: View {
    let library: BibleLibrary
    @Binding var requestedVerseID: String?
    @AppStorage("kjv.readingReference") private var savedReference = "GEN.1.1"
    @AppStorage("reader.fontSize") private var fontSize = 30.0
    @State private var verseIndex = 0
    @State private var restoredPosition = false
    @State private var sheet: ReaderSheet?
    @EnvironmentObject private var savedVerses: SavedVersesStore
    @EnvironmentObject private var readingProgress: ReadingProgress
    @EnvironmentObject private var interactions: VerseInteractions
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var chapterCelebration: ChapterCelebration?
    @State private var completedChapterCount = 0

    private var currentVerse: Verse {
        library.verses[verseIndex]
    }

    private var chapterVerseCount: Int {
        guard let book = library.books.first(where: { $0.id == currentVerse.bookID }) else { return 0 }
        return book.chapters[currentVerse.chapter - 1].count
    }

    var body: some View {
        NavigationStack {
            VersePager(count: library.verses.count, index: $verseIndex,
                       revision: "\(fontSize)|\(savedVerses.verseIDs.joined(separator: ","))",
                       onSwipeCompleted: { previous, next in
                           guard let chapter = library.completedChapter(from: previous, to: next) else { return }
                           readingProgress.markDone(bookID: chapter.bookID, chapter: chapter.chapter)
                           withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.4, bounce: 0.15)) {
                               chapterCelebration = ChapterCelebration(
                                   finished: "\(chapter.bookName) \(chapter.chapter)",
                                   next: "\(library.verses[next].bookName) \(library.verses[next].chapter)")
                           }
                           completedChapterCount += 1
                       }) { index in
                let verse = library.verses[index]
                return VersePage(verse: verse, fontSize: fontSize,
                          isLast: index == library.verses.count - 1,
                          isSaved: savedVerses.contains(verse.id),
                          toggleSave: { savedVerses.toggle(verse.id) },
                          openAnalysis: { sheet = .analysis(verse) },
                          translationID: library.translationID,
                          interactions: interactions,
                          openNotes: { sheet = .notes(verse) })
            }
            .onAppear {
                if let requested = requestedVerseID {
                    verseIndex = library.indexByID[requested] ?? 0
                    requestedVerseID = nil
                    restoredPosition = true
                } else if !restoredPosition {
                    verseIndex = library.indexByID[savedReference] ?? 0
                    restoredPosition = true
                }
            }
            .onChange(of: requestedVerseID) { _, reference in
                guard let reference else { return }
                verseIndex = library.indexByID[reference] ?? 0
                requestedVerseID = nil
            }
            .onChange(of: verseIndex) { _, index in
                savedReference = library.verses[index].id
            }
            .sheet(item: $sheet) { selectedSheet in
                switch selectedSheet {
                case .books:
                    BookPicker(books: library.books, current: currentVerse, progress: readingProgress) { book, chapter in
                        verseIndex = library.indexByID["\(book.id).\(chapter).1"] ?? 0
                        sheet = nil
                    }
                case .translation: TranslationSheet()
                case .settings: ReadingSettings(fontSize: $fontSize)
                case .analysis(let verse):
                    VerseAnalysisView(verse: verse, library: library)
                case .notes(let verse):
                    VerseNotesView(verse: verse, translationID: library.translationID, interactions: interactions)
                case .saved:
                    SavedVersesView(library: library, store: savedVerses) { verse in
                        verseIndex = library.indexByID[verse.id] ?? 0
                        sheet = nil
                    }
                }
            }
            .background(AppStyle.backdrop)
            .overlay(alignment: .top) {
                if let celebration = chapterCelebration {
                    ChapterCompletionBanner(celebration: celebration)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                        .allowsHitTesting(false)
                }
            }
            .sensoryFeedback(.success, trigger: completedChapterCount)
            .task(id: chapterCelebration?.id) {
                guard chapterCelebration != nil else { return }
                do { try await Task.sleep(for: .seconds(2.2)) } catch { return }
                withAnimation(.easeOut(duration: 0.25)) { chapterCelebration = nil }
            }
            .overlay(alignment: .leading) {
                ChapterProgressIndicator(verse: currentVerse.number, total: chapterVerseCount) { number in
                    let id = "\(currentVerse.bookID).\(currentVerse.chapter).\(number)"
                    if let index = library.indexByID[id], index != verseIndex {
                        verseIndex = index
                    }
                }
                    .frame(width: 44)
                    .padding(.vertical, 20)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                readerHeader
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var readerHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            headerTools
            Spacer(minLength: 0)
            passageSelector
                .layoutPriority(1)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppStyle.canvas)
    }

    private var headerTools: some View {
        HStack(spacing: 8) {
            Button { sheet = .translation } label: {
                Text(library.translationID).font(.subheadline.weight(.semibold)).readerPill()
            }
            .accessibilityLabel("Choose Bible translation, King James Version")
            Button { sheet = .saved } label: {
                Image(systemName: "bookmark").frame(width: 20).readerPill()
            }
            .accessibilityLabel("Bookmark")
            Button { sheet = .settings } label: {
                Image(systemName: "textformat.size").frame(width: 20).readerPill()
            }
            .accessibilityLabel("Reading settings")
        }
        .fixedSize(horizontal: true, vertical: true)
    }

    private var passageSelector: some View {
        Button { sheet = .books } label: {
            HStack(spacing: 7) {
                (
                    Text(currentVerse.bookName).fontWeight(.semibold).foregroundColor(.primary)
                    + Text(" \(currentVerse.chapter):\(currentVerse.number)").foregroundColor(.secondary)
                )
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(AppStyle.paper, in: Capsule())
            .overlay(Capsule().stroke(AppStyle.border, lineWidth: 1))
            .contentShape(Capsule())
        }
        .accessibilityLabel("Choose book and chapter, currently at \(currentVerse.reference)")
    }

}

private enum ReaderSheet: Identifiable {
    case books, translation, settings, saved
    case analysis(Verse)
    case notes(Verse)
    var id: String {
        switch self {
        case .books: return "books"
        case .translation: return "translation"
        case .settings: return "settings"
        case .saved: return "saved"
        case .analysis(let verse): return "analysis.\(verse.id)"
        case .notes(let verse): return "notes.\(verse.id)"
        }
    }
}

struct VersePage: View {
    let verse: Verse
    let fontSize: Double
    let isLast: Bool
    let isSaved: Bool
    let toggleSave: () -> Void
    let openAnalysis: () -> Void
    let translationID: String
    let interactions: VerseInteractions
    let openNotes: () -> Void
    var endMessage = "End of the Bible"
    var verticalPadding: CGFloat = 24
    @ScaledMetric(relativeTo: .title) private var textScale = 1.0
    @State private var section = 0

    private var readingFont: UIFont {
        let base = UIFont.systemFont(ofSize: fontSize * textScale)
        return UIFont(descriptor: base.fontDescriptor.withDesign(.serif) ?? base.fontDescriptor,
                      size: base.pointSize)
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Spacer(minLength: 0)
                Button(action: openAnalysis) {
                    Label("Verse analysis", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(AppStyle.bronze)
                        .background(AppStyle.paper, in: Capsule())
                        .overlay(Capsule().stroke(AppStyle.border, lineWidth: 1))
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Verse analysis for \(verse.reference)")
            }

            GeometryReader { area in
                let parts = VersePagination.sections(verse.text) { candidate in
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = 8
                    let bounds = (candidate as NSString).boundingRect(
                        with: CGSize(width: max(1, area.size.width - 8), height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: [.font: readingFont, .paragraphStyle: style], context: nil)
                    return ceil(bounds.height) + readingFont.lineHeight <= max(1, area.size.height - 60)
                }
                let index = min(section, parts.count - 1)
                VStack(spacing: 12) {
                    Text(parts[index])
                        .font(Font(readingFont))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    if parts.count > 1 {
                        HStack(spacing: 16) {
                            Button {
                                section = max(0, index - 1)
                            } label: {
                                Image(systemName: "chevron.left").frame(width: 44, height: 44)
                            }
                            .disabled(index == 0)
                            .accessibilityLabel("Previous part")
                            Text("Part \(index + 1) of \(parts.count)")
                                .font(.caption).foregroundStyle(.secondary)
                            Button {
                                section = min(parts.count - 1, index + 1)
                            } label: {
                                Image(systemName: "chevron.right").frame(width: 44, height: 44)
                            }
                            .disabled(index == parts.count - 1)
                            .accessibilityLabel("Next part")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: area.size.width, height: area.size.height)
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture(minimumDistance: 25).onEnded { drag in
                    guard abs(drag.translation.width) > abs(drag.translation.height),
                          abs(drag.translation.width) > 40 else { return }
                    // Swipe left to advance; swipe right to return.
                    section = min(parts.count - 1, max(0, index + (drag.translation.width < 0 ? 1 : -1)))
                })
                .onChange(of: area.size) { _, _ in section = 0 }
            }
            Text(verse.reference)
                .font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
            HStack {
                Button(action: toggleSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .frame(width: 46, height: 46)
                        .background(AppStyle.surface, in: Circle())
                        .overlay(Circle().stroke(AppStyle.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isSaved ? "Remove bookmark for \(verse.reference)" : "Bookmark \(verse.reference)")
                .accessibilityValue(isSaved ? "Bookmarked" : "Not bookmarked")
                Spacer(minLength: 8)
                VerseActionButtons(verse: verse, translationID: translationID,
                                   interactions: interactions, openNotes: openNotes)
            }
            if isLast {
                Text(endMessage).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 44)
        .padding(.vertical, verticalPadding)
        .onChange(of: fontSize) { _, _ in section = 0 }
        .onChange(of: textScale) { _, _ in section = 0 }
        .onChange(of: verse.id) { _, _ in section = 0 }
        .sensoryFeedback(.selection, trigger: section)
    }
}

private extension View {
    func readerPill() -> some View {
        padding(.horizontal, 12).frame(minHeight: 44)
            .background(AppStyle.paper, in: Capsule())
            .overlay(Capsule().stroke(AppStyle.border, lineWidth: 1))
    }
}

#Preview { AppTabs() }
