import Foundation

struct Devotional: Decodable, Identifiable {
    let id: String
    /// A local publication date, not a UTC timestamp (YYYY-MM-DD).
    let date: String
    let series: String
    let seriesDay: Int
    let title: String
    /// Canonical verse IDs, resolved using the selected Bible version.
    let scriptureReferences: [String]
    let introduction: String
    let reflection: String
    let application: String
    let prayer: String
    let author: String

    func readingMinutes(in bible: BibleLibrary) -> Int {
        let scripture = scriptureReferences.compactMap { reference in
            bible.indexByID[reference].map { bible.verses[$0].text }
        }.joined(separator: " ")
        let text = [introduction, scripture, reflection, application, prayer].joined(separator: " ")
        let words = text.split(whereSeparator: \.isWhitespace).count
        return max(1, Int(ceil(Double(words) / 180)))
    }
}

struct DevotionalLibrary {
    let entries: [Devotional]
    private let byDate: [String: Devotional]

    init(bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "devotionals", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        try self.init(url: url)
    }

    init(url: URL) throws {
        let decoded = try JSONDecoder().decode([Devotional].self, from: Data(contentsOf: url))
        guard Set(decoded.map(\.date)).count == decoded.count,
              decoded.allSatisfy({ $0.id == $0.date }) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        entries = decoded.sorted { $0.date < $1.date }
        byDate = Dictionary(uniqueKeysWithValues: entries.map { ($0.date, $0) })
    }

    func devotional(on date: Date, calendar: Calendar = .current) -> Devotional? {
        byDate[Self.dateKey(date, calendar: calendar)]
    }

    static func dateKey(_ date: Date, calendar: Calendar = .current) -> String {
        // Publication dates use the Gregorian calendar, in the user's time zone.
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let components = gregorian.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
}
