import Combine
import Foundation

final class ReadingProgress: ObservableObject {
    @Published private(set) var completedChapters: Set<String>
    private let defaults: UserDefaults
    private let storageKey = "reading.completedChapters"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        completedChapters = Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    // Canonical book IDs (GEN, EXO, etc.) are shared across translations.
    // Completion represents reading a chapter, regardless of translation.
    func isDone(bookID: String, chapter: Int) -> Bool {
        completedChapters.contains("\(bookID).\(chapter)")
    }

    func toggleChapter(bookID: String, chapter: Int) {
        let id = "\(bookID).\(chapter)"
        if completedChapters.contains(id) {
            completedChapters.remove(id)
        } else {
            completedChapters.insert(id)
        }
        save()
    }

    func markDone(bookID: String, chapter: Int) {
        guard completedChapters.insert("\(bookID).\(chapter)").inserted else { return }
        save()
    }

    func completedCount(bookID: String, chapterCount: Int) -> Int {
        guard chapterCount > 0 else { return 0 }
        return (1...chapterCount).filter { isDone(bookID: bookID, chapter: $0) }.count
    }

    func toggleBook(bookID: String, chapterCount: Int) {
        guard chapterCount > 0 else { return }
        let ids = Set((1...chapterCount).map { "\(bookID).\($0)" })
        if ids.isSubset(of: completedChapters) {
            completedChapters.subtract(ids)
        } else {
            completedChapters.formUnion(ids)
        }
        save()
    }

    private func save() {
        defaults.set(completedChapters.sorted(), forKey: storageKey)
    }
}
