import Foundation

enum DailyVerse {
    /// A stable, non-sequential daily rotation through every verse in the library.
    static func reference(on date: Date, in bible: BibleLibrary, calendar: Calendar = .current) -> String {
        let count = bible.verses.count
        guard count > 0 else { return "GEN.1.1" }
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let day = gregorian.ordinality(of: .day, in: .era, for: date) ?? 1

        // A coprime step visits every verse before repeating. Recalculate for
        // the active library so future translations can have different counts.
        var step = min(7_919, count)
        while gcd(step, count) != 1 { step -= 1 }
        let index = (((day - 1) % count) * step) % count
        return bible.verses[index].id
    }

    private static func gcd(_ lhs: Int, _ rhs: Int) -> Int {
        var a = lhs
        var b = rhs
        while b != 0 { (a, b) = (b, a % b) }
        return a
    }
}
