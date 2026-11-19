import Foundation

@main
struct ReadingProgressTests {
    static func main() {
        let suite = "BibleScroll.ProgressTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let progress = ReadingProgress(defaults: defaults)
        precondition(!progress.isDone(bookID: "GAL", chapter: 1))
        progress.toggleChapter(bookID: "GAL", chapter: 1)
        progress.toggleChapter(bookID: "GEN", chapter: 1)
        precondition(progress.completedCount(bookID: "GAL", chapterCount: 6) == 1)
        let reopened = ReadingProgress(defaults: defaults)
        precondition(reopened.isDone(bookID: "GAL", chapter: 1))
        reopened.toggleBook(bookID: "GAL", chapterCount: 6)
        precondition(reopened.completedCount(bookID: "GAL", chapterCount: 6) == 6)
        reopened.toggleBook(bookID: "GAL", chapterCount: 6)
        precondition(reopened.completedCount(bookID: "GAL", chapterCount: 6) == 0)
        precondition(reopened.isDone(bookID: "GEN", chapter: 1))
        reopened.toggleChapter(bookID: "GEN", chapter: 1)
        precondition(ReadingProgress(defaults: defaults).completedChapters.isEmpty)
        // No translation identifier is used: the same canonical chapter shares progress.
        precondition(progress.completedCount(bookID: "GEN", chapterCount: 0) == 0)
        print("Passed: chapter toggle, persistence, partial/full book toggles, isolation between books, undo.")
    }
}
