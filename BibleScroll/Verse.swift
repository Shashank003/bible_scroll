import Foundation

struct BibleBook: Decodable, Identifiable {
    let id: String
    let name: String
    let chapters: [[String]]
}

struct Verse: Identifiable {
    let bookID: String
    let bookName: String
    let chapter: Int
    let number: Int
    let text: String
    var id: String { "\(bookID).\(chapter).\(number)" }
    var reference: String { "\(bookName) \(chapter):\(number)" }
}

struct BibleLibrary {
    let translationID: String
    let books: [BibleBook]
    let verses: [Verse]
    let indexByID: [String: Int]

    /// Only an adjacent forward transition from a chapter's final verse counts.
    /// A jump from the picker, restoration, or backward swipe does not.
    func completedChapter(from oldIndex: Int, to newIndex: Int) -> Verse? {
        guard verses.indices.contains(oldIndex), verses.indices.contains(newIndex),
              newIndex == oldIndex + 1 else { return nil }
        let previous = verses[oldIndex]
        let next = verses[newIndex]
        guard next.number == 1,
              next.bookID != previous.bookID || next.chapter != previous.chapter,
              let book = books.first(where: { $0.id == previous.bookID }),
              previous.number == book.chapters[previous.chapter - 1].count else { return nil }
        return previous
    }

    init(translationID: String = "KJV") throws {
        self.translationID = translationID
        guard ["KJV", "WEB"].contains(translationID),
              let url = Bundle.main.url(forResource: translationID.lowercased(), withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        books = try JSONDecoder().decode([BibleBook].self, from: Data(contentsOf: url))
        verses = books.flatMap { book in
            book.chapters.enumerated().flatMap { chapter, texts in
                texts.enumerated().map { number, text in
                    let displayText = text.isEmpty
                        ? "This verse number has no text in this edition. Continue to the next verse." : text
                    return Verse(bookID: book.id, bookName: book.name, chapter: chapter + 1,
                                 number: number + 1, text: displayText)
                }
            }
        }
        indexByID = Dictionary(uniqueKeysWithValues: verses.enumerated().map { ($0.element.id, $0.offset) })
    }
}
