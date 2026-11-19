import Foundation

struct PlanChapter: Identifiable {
    let bookID: String
    let chapter: Int
    var id: String { "\(bookID).\(chapter)" }
    var firstVerseID: String { "\(id).1" }

    func label(in bible: BibleLibrary) -> String {
        "\(bible.books.first(where: { $0.id == bookID })?.name ?? bookID) \(chapter)"
    }
}

struct ReadingPlan: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let symbol: String
    let artwork: String
    let days: [[PlanChapter]]
    let dailyMinutes: [Int]

    /// Average at 180 words per minute; time for reflection is additional.
    var estimatedMinutesPerDay: Int {
        max(1, Int((Double(dailyMinutes.reduce(0, +)) / Double(max(1, dailyMinutes.count))).rounded(.up)))
    }

    func readingLabel(day: Int, in bible: BibleLibrary) -> String {
        guard days.indices.contains(day), let first = days[day].first, let last = days[day].last else { return "" }
        if days[day].count == 1 { return first.label(in: bible) }
        if first.bookID == last.bookID { return "\(first.label(in: bible))–\(last.chapter)" }
        return days[day].map { $0.label(in: bible) }.joined(separator: " · ")
    }

    static func catalog(in bible: BibleLibrary) -> [ReadingPlan] {
        func chapters(_ books: [BibleBook]) -> [PlanChapter] {
            books.flatMap { book in (1...book.chapters.count).map { PlanChapter(bookID: book.id, chapter: $0) } }
        }
        func make(_ id: String, _ title: String, _ subtitle: String, _ description: String,
                  _ symbol: String, _ artwork: String, _ books: [BibleBook], _ duration: Int) -> ReadingPlan? {
            let readings = chapters(books)
            guard !readings.isEmpty else { return nil }
            let count = min(duration, readings.count)
            let days = (0..<count).map { day in
                Array(readings[(day * readings.count / count)..<((day + 1) * readings.count / count)])
            }
            let booksByID = Dictionary(uniqueKeysWithValues: books.map { ($0.id, $0) })
            let dailyMinutes = days.map { chapters in
                let words = chapters.reduce(0) { total, reading in
                    total + (booksByID[reading.bookID]?.chapters[reading.chapter - 1].reduce(0) {
                        $0 + $1.split(whereSeparator: { $0.isWhitespace }).count
                    } ?? 0)
                }
                return max(1, Int(ceil(Double(words) / 180)))
            }
            return ReadingPlan(id: id, title: title, subtitle: subtitle, description: description,
                               symbol: symbol, artwork: artwork, days: days, dailyMinutes: dailyMinutes)
        }
        return [
            make("john-21", "Start with John", "One chapter. A little closer.",
                 "Spend 21 readings in the Gospel of John, following the signs, conversations, and teaching of Jesus. One chapter at a time, at your own pace.",
                 "sun.horizon", "DevotionalJanuary", bible.books.filter { $0.id == "JOH" }, 21),
            make("genesis-25", "In the Beginning", "Genesis in 25 readings",
                 "Read all of Genesis, two chapters per reading. Follow its stories of creation, promise, family, struggle, and faithfulness.",
                 "leaf", "DevotionalDecember", bible.books.filter { $0.id == "GEN" }, 25),
            make("psalms-30", "A Psalm a Day", "Thirty moments of prayer",
                 "Read Psalms 1–30, one psalm per reading. Make space for praise, questions, lament, and trust in the language of prayer.",
                 "wind", "DevotionalJanuary", bible.books.filter { $0.id == "PSA" }.map {
                     BibleBook(id: $0.id, name: $0.name, chapters: Array($0.chapters.prefix(30)))
                 }, 30),
            make("new-testament-90", "Walk Through the New Testament", "A wider view in 90 readings",
                 "Read every New Testament chapter in order, from Matthew to Revelation. Each reading contains two or three chapters, with room to continue at your own pace.",
                 "book.pages", "DevotionalDecember", Array(bible.books.dropFirst(39)), 90),
            make("bible-365", "The Whole Story", "The Bible in a year",
                 "Read the complete Bible in canonical order over 365 readings. Three or four chapters per reading take you from Genesis through Revelation.",
                 "books.vertical", "DevotionalJanuary", bible.books, 365)
        ].compactMap { $0 }
    }
}
