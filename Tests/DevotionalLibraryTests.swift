import Foundation

@main
struct DevotionalLibraryTests {
    static func main() throws {
        let library = try DevotionalLibrary(url: URL(fileURLWithPath: CommandLine.arguments[1]))
        precondition(library.entries.count == 62)
        precondition(library.entries.first?.date == "2026-12-01")
        precondition(library.entries.last?.date == "2027-01-31")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
        }
        precondition(library.devotional(on: date(2026, 11, 30, hour: 23), calendar: calendar) == nil)
        precondition(library.devotional(on: date(2026, 12, 1), calendar: calendar)?.id == "2026-12-01")
        precondition(library.devotional(on: date(2026, 12, 31, hour: 23), calendar: calendar)?.id == "2026-12-31")
        precondition(library.devotional(on: date(2027, 1, 1), calendar: calendar)?.id == "2027-01-01")
        precondition(library.devotional(on: date(2027, 2, 1), calendar: calendar) == nil)
        // Local midnight is still the preceding UTC date.
        var utc = calendar
        utc.timeZone = TimeZone(secondsFromGMT: 0)!
        let localMidnight = date(2027, 1, 1)
        precondition(DevotionalLibrary.dateKey(localMidnight, calendar: utc) == "2026-12-31")
        precondition(DevotionalLibrary.dateKey(localMidnight, calendar: calendar) == "2027-01-01")
        let bible = try BibleLibrary()
        for devotional in library.entries {
            precondition(devotional.scriptureReferences.allSatisfy { bible.indexByID[$0] != nil })
            precondition(devotional.readingMinutes(in: bible) >= 1)
        }
        print("Passed: all 62 dates, month/year boundaries, local midnight vs UTC, missing-date behavior, references, and reading estimates.")
    }
}
