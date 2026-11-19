import Combine
import Foundation

final class ReadingActivity: ObservableObject {
    @Published private(set) var openedDays: Set<String>
    private let defaults: UserDefaults
    private let key = "activity.openedDays"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        openedDays = Set(defaults.stringArray(forKey: key) ?? [])
    }

    private func dayKey(_ date: Date, calendar: Calendar) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    func recordOpen(at date: Date = .now, calendar: Calendar = .current) {
        guard openedDays.insert(dayKey(date, calendar: calendar)).inserted else { return }
        defaults.set(openedDays.sorted(), forKey: key)
    }

    func wasOpened(on date: Date, calendar: Calendar = .current) -> Bool {
        openedDays.contains(dayKey(date, calendar: calendar))
    }

    func streak(on date: Date = .now, calendar: Calendar = .current) -> Int {
        var cursor = calendar.startOfDay(for: date)
        if !wasOpened(on: cursor, calendar: calendar) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
        }
        var count = 0
        while wasOpened(on: cursor, calendar: calendar) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    func bestStreak(calendar: Calendar = .current) -> Int {
        let dates = openedDays.compactMap { key -> Date? in
            let pieces = key.split(separator: "-").compactMap { Int($0) }
            guard pieces.count == 3 else { return nil }
            return calendar.date(from: DateComponents(year: pieces[0], month: pieces[1], day: pieces[2]))
        }.sorted()
        var best = 0
        var run = 0
        var previous: Date?
        for date in dates {
            run = previous.map { calendar.dateComponents([.day], from: $0, to: date).day == 1 } == true ? run + 1 : 1
            best = max(best, run)
            previous = date
        }
        return best
    }
}
