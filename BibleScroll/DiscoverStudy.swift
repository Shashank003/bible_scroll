import Combine
import Foundation

struct DiscoverStudy: Identifiable, Decodable {
    enum Kind: String, Decodable { case scripture, reflection, fact }
    let id: String
    let kind: Kind
    let verseID: String
    let theme: String
    let body: String
    let meaning: String
    let context: String
    let application: String
    let related: [String]
    let sources: [String]
    let attribution: String

    static let catalog: [DiscoverStudy] = {
        guard let url = Bundle.main.url(forResource: "discover", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cards = try? JSONDecoder().decode([DiscoverStudy].self, from: data) else { return [] }
        return cards
    }()

    static func mixedOrder() -> [String] {
        let verses = catalog.filter { $0.kind == .scripture }.shuffled()
        let reflections = catalog.filter { $0.kind == .reflection }.shuffled()
        let facts = catalog.filter { $0.kind == .fact }.shuffled()
        var result: [String] = []
        for index in 0..<max(verses.count, max(reflections.count, facts.count)) {
            if index < verses.count {
                result.append(verses[index].id)
            }
            // Three Scripture cards followed by a reflection and a fact.
            if index % 3 == 2 || index == verses.count - 1 {
                let extra = index / 3
                if extra < reflections.count { result.append(reflections[extra].id) }
                if extra < facts.count { result.append(facts[extra].id) }
            }
        }
        return result
    }
}

final class DiscoverProgress: ObservableObject {
    @Published private(set) var order: [String]
    @Published private(set) var completed: Set<String>
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let valid = Set(DiscoverStudy.catalog.map(\.id))
        var seen = Set<String>()
        let previous = (defaults.stringArray(forKey: "discover.order") ?? [])
            .filter { valid.contains($0) && seen.insert($0).inserted }
        order = Set(previous) == valid ? previous : DiscoverStudy.mixedOrder()
        completed = Set(defaults.stringArray(forKey: "discover.completed") ?? [])
        defaults.set(order, forKey: "discover.order")
    }

    func shuffle() {
        order = DiscoverStudy.mixedOrder()
        defaults.set(order, forKey: "discover.order")
    }

    func isDone(_ id: String, translation: String) -> Bool {
        completed.contains("\(translation):\(id)")
    }

    func toggle(_ id: String, translation: String) {
        let key = "\(translation):\(id)"
        if completed.contains(key) { completed.remove(key) } else { completed.insert(key) }
        defaults.set(completed.sorted(), forKey: "discover.completed")
    }
}
