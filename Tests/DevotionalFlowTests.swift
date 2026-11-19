import Foundation

@main
struct DevotionalFlowTests {
    static func main() throws {
        let library = try DevotionalLibrary(url: URL(fileURLWithPath: CommandLine.arguments[1]))
        let bible = try BibleLibrary()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
        }
        let suite = "BibleScroll.DevotionalFlow.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = DevotionalStore(defaults: defaults, library: library)
        let first = library.entries[0]
        precondition(store.featured(on: date(2026, 11, 17), calendar: calendar)?.id == "2026-12-01")
        precondition(store.featured(on: date(2026, 12, 25), calendar: calendar)?.id == "2026-12-25")
        precondition(store.featured(on: date(2027, 2, 1), calendar: calendar)?.id == "2027-01-31")
        // Readings can be completed regardless of their scheduled date.
        precondition(store.completed.isEmpty)
        store.finish(first)
        store.finish(first)
        precondition(store.completed.count == 1)
        store.toggleBookmark(first)
        store.savePosition("prayer", devotional: first, translation: "KJV")
        let reopened = DevotionalStore(defaults: defaults, library: library)
        precondition(reopened.completed.contains(first.id))
        reopened.savePosition("intro", devotional: first, translation: "KJV")
        precondition(reopened.completed.contains(first.id))
        precondition(reopened.position(for: first, translation: "KJV") == "intro")
        reopened.savePosition("prayer", devotional: first, translation: "KJV")
        precondition(reopened.bookmarks.contains(first.id))
        precondition(reopened.position(for: first, translation: "KJV") == "prayer")
        precondition(reopened.position(for: first, translation: "NLT") == nil)
        reopened.toggleBookmark(first)
        precondition(!reopened.bookmarks.contains(first.id))
        for devotional in library.entries {
            let steps = DevotionalReadingStep.make(devotional: devotional, bible: bible)
            precondition(steps.first?.id == "intro" && steps.last?.id == "finish")
            precondition(Set(steps.map(\.id)).count == steps.count)
            func normalize(_ value: String) -> String { value.split(whereSeparator: \.isWhitespace).joined(separator: " ") }
            let reflection = steps.filter { $0.kind == .reflection }.map(\.text).joined(separator: " ")
            precondition(normalize(reflection) == normalize(devotional.reflection))
            let scripture = steps.filter { $0.kind == .scripture }.map(\.text).joined(separator: " ")
            let expected = devotional.scriptureReferences.map { bible.verses[bible.indexByID[$0]!].text }.joined(separator: " ")
            precondition(normalize(scripture) == normalize(expected))
            precondition(steps.contains { $0.kind == .application && $0.text == devotional.application })
            precondition(steps.contains { $0.kind == .prayer && $0.text == devotional.prayer })
        }
        print("Passed: featured-date states, unrestricted reading completion, idempotent completion, bookmarks, translation-specific resume, and lossless reading steps for all 62 devotionals.")
    }
}
