import Foundation

@main
struct HomeDataTests {
    static func main() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        func date(_ day: Int, hour: Int = 9) -> Date {
            calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour))!
        }
        let library = try BibleLibrary()
        let reference = DailyVerse.reference(on: date(17), in: library, calendar: calendar)
        precondition(reference == DailyVerse.reference(on: date(17, hour: 23), in: library, calendar: calendar))
        precondition(reference != DailyVerse.reference(on: date(18), in: library, calendar: calendar))
        precondition(library.indexByID[reference] != nil)
        for day in 1...30 {
            precondition(library.indexByID[DailyVerse.reference(on: date(day), in: library, calendar: calendar)] != nil)
        }
        // Across one complete cycle, every verse is eligible exactly once.
        var seen = Set<String>()
        let start = calendar.startOfDay(for: date(1))
        for offset in 0..<library.verses.count {
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            seen.insert(DailyVerse.reference(on: day, in: library, calendar: calendar))
        }
        precondition(seen == Set(library.verses.map(\.id)))
        let afterThirtyDays = calendar.date(byAdding: .day, value: 30, to: date(17))!
        precondition(reference != DailyVerse.reference(on: afterThirtyDays, in: library, calendar: calendar))
        let suite = "BibleScroll.HomeTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let activity = ReadingActivity(defaults: defaults)
        for day in [10, 11, 12, 15, 16, 17] { activity.recordOpen(at: date(day), calendar: calendar) }
        activity.recordOpen(at: date(17, hour: 23), calendar: calendar)
        precondition(activity.openedDays.count == 6)
        precondition(activity.streak(on: date(17), calendar: calendar) == 3)
        precondition(activity.streak(on: date(18), calendar: calendar) == 3)
        precondition(activity.streak(on: date(19), calendar: calendar) == 0)
        precondition(activity.bestStreak(calendar: calendar) == 3)
        let reopened = ReadingActivity(defaults: defaults)
        precondition(reopened.openedDays == activity.openedDays)
        precondition(reopened.wasOpened(on: date(17), calendar: calendar))
        print("Passed: stable daily verse, midnight rollover, valid references, opening-streak gaps, duplicate opens, best streak, and persistence.")
    }
}
