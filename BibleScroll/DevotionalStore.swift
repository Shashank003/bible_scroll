import Combine
import Foundation

final class DevotionalStore: ObservableObject {
    let library: DevotionalLibrary?
    @Published private(set) var completed: Set<String>
    @Published private(set) var bookmarks: Set<String>
    @Published private(set) var readingPositions: [String: String]
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, library: DevotionalLibrary? = try? DevotionalLibrary()) {
        self.defaults = defaults
        self.library = library
        completed = Set(defaults.stringArray(forKey: "devotional.completed") ?? [])
        bookmarks = Set(defaults.stringArray(forKey: "devotional.bookmarks") ?? [])
        readingPositions = defaults.dictionary(forKey: "devotional.positions") as? [String: String] ?? [:]
    }

    func featured(on date: Date, calendar: Calendar = .current) -> Devotional? {
        guard let library else { return nil }
        if let today = library.devotional(on: date, calendar: calendar) { return today }
        let key = DevotionalLibrary.dateKey(date, calendar: calendar)
        return library.entries.first(where: { $0.date > key }) ?? library.entries.last
    }

    func toggleBookmark(_ devotional: Devotional) {
        if bookmarks.contains(devotional.id) { bookmarks.remove(devotional.id) }
        else { bookmarks.insert(devotional.id) }
        defaults.set(bookmarks.sorted(), forKey: "devotional.bookmarks")
    }

    func finish(_ devotional: Devotional) {
        if completed.insert(devotional.id).inserted {
            defaults.set(completed.sorted(), forKey: "devotional.completed")
        }
    }

    func savePosition(_ step: String, devotional: Devotional, translation: String) {
        readingPositions["\(translation):\(devotional.id)"] = step
        defaults.set(readingPositions, forKey: "devotional.positions")
    }

    func position(for devotional: Devotional, translation: String) -> String? {
        readingPositions["\(translation):\(devotional.id)"]
    }
}

extension Devotional {
    var artwork: String { date.hasPrefix("2026-12") ? "DevotionalDecember" : "DevotionalJanuary" }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let day = formatter.date(from: date) else { return date }
        return day.formatted(.dateTime.month(.abbreviated).day().year())
    }

    func passageLabel(in bible: BibleLibrary) -> String {
        scriptureReferences.compactMap { reference in
            bible.indexByID[reference].map { bible.verses[$0].reference }
        }.joined(separator: " · ")
    }
}
