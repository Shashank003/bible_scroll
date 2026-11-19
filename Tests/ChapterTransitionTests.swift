import Foundation

@main
struct ChapterTransitionTests {
    static func main() throws {
        let library = try BibleLibrary()
        var boundaries = 0
        var bookBoundaries = 0
        for index in 0..<(library.verses.count - 1) {
            let verse = library.verses[index]
            let next = library.verses[index + 1]
            let boundary = verse.bookID != next.bookID || verse.chapter != next.chapter
            let result = library.completedChapter(from: index, to: index + 1)
            precondition((result != nil) == boundary)
            if boundary {
                boundaries += 1
                precondition(result?.id == verse.id)
                if verse.bookID != next.bookID { bookBoundaries += 1 }
            }
            precondition(library.completedChapter(from: index + 1, to: index) == nil)
            precondition(library.completedChapter(from: index, to: index + 2) == nil)
        }
        precondition(boundaries == 1188 && bookBoundaries == 65)
        precondition(library.completedChapter(from: -1, to: 0) == nil)
        precondition(library.completedChapter(from: 31101, to: 31102) == nil)
        let suite = "BibleScroll.ChapterTransitionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let progress = ReadingProgress(defaults: defaults)
        progress.markDone(bookID: "GEN", chapter: 1)
        progress.markDone(bookID: "GEN", chapter: 1)
        precondition(progress.completedChapters.count == 1)
        precondition(ReadingProgress(defaults: defaults).isDone(bookID: "GEN", chapter: 1))
        print("Passed: all 1,188 chapter transitions, all 65 book boundaries, no backwards/jump completion, idempotence and persistence.")
    }
}
