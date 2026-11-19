import Combine
import Foundation

final class SavedVersesStore: ObservableObject {
    @Published private(set) var verseIDs: [String]
    private let defaults: UserDefaults
    private let key = "kjv.savedVerseIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var seen = Set<String>()
        verseIDs = (defaults.stringArray(forKey: key) ?? []).filter { seen.insert($0).inserted }
    }

    func contains(_ id: String) -> Bool { verseIDs.contains(id) }

    func toggle(_ id: String) {
        if contains(id) {
            remove(id)
        } else {
            verseIDs.insert(id, at: 0)
            persist()
        }
    }

    func remove(_ id: String) {
        verseIDs.removeAll { $0 == id }
        persist()
    }

    private func persist() {
        defaults.set(verseIDs, forKey: key)
    }
}
