import Foundation

@main
struct DiscoverProgressTests {
    static func main() throws {
        let books = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[String: Any]]
        var references = Set<String>()
        for book in books {
            for (chapter, verses) in (book["chapters"] as! [[String]]).enumerated() {
                for verse in verses.indices {
                    references.insert("\(book["id"] as! String).\(chapter + 1).\(verse + 1)")
                }
            }
        }
        let ids = DiscoverStudy.catalog.map(\.id)
        precondition(ids.count == 50)
        precondition(DiscoverStudy.catalog.filter { $0.kind == .scripture }.count == 30)
        precondition(DiscoverStudy.catalog.filter { $0.kind == .reflection }.count == 10)
        precondition(DiscoverStudy.catalog.filter { $0.kind == .fact }.count == 10)
        precondition(Set(ids).count == ids.count)
        for study in DiscoverStudy.catalog {
            precondition(references.contains(study.verseID))
            precondition(!study.body.isEmpty)
            precondition(study.sources.allSatisfy { references.contains($0) })
            if study.kind == .scripture {
                precondition(!study.meaning.isEmpty && !study.context.isEmpty && !study.application.isEmpty)
            }
            precondition(study.related.allSatisfy { references.contains($0) })
        }
        let suite = "BibleScroll.DiscoverTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let progress = DiscoverProgress(defaults: defaults)
        precondition(Set(progress.order) == Set(ids))
        let kinds = Dictionary(uniqueKeysWithValues: DiscoverStudy.catalog.map { ($0.id, $0.kind) })
        for start in stride(from: 0, to: 50, by: 5) {
            precondition(progress.order[start..<start+3].allSatisfy { kinds[$0] == .scripture })
            precondition(kinds[progress.order[start+3]] == .reflection)
            precondition(kinds[progress.order[start+4]] == .fact)
        }
        let original = progress.order
        precondition(DiscoverProgress(defaults: defaults).order == original)
        progress.toggle(ids[0], translation: "KJV")
        let reopened = DiscoverProgress(defaults: defaults)
        precondition(reopened.isDone(ids[0], translation: "KJV"))
        precondition(!reopened.isDone(ids[0], translation: "NLT"))
        reopened.toggle(ids[0], translation: "KJV")
        precondition(!reopened.isDone(ids[0], translation: "KJV"))
        reopened.shuffle()
        precondition(Set(reopened.order) == Set(ids))
        precondition(DiscoverProgress(defaults: defaults).order == reopened.order)
        defaults.set([ids[0], ids[0], "INVALID"], forKey: "discover.order")
        precondition(Set(DiscoverProgress(defaults: defaults).order) == Set(ids))
        precondition(DiscoverProgress(defaults: defaults).order.count == ids.count)
        print("Passed: all study references, stable shuffled order, shuffle persistence, completion/undo, translation isolation, invalid-order recovery.")
    }
}
