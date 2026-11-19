import Combine
import Foundation

/// Personal data belongs to the canonical verse, shared across translations.
final class VerseInteractions: ObservableObject {
    struct Entry: Codable {
        var liked = false
        var note = ""
    }

    @Published private var entries: [String: Entry]
    private let defaults: UserDefaults
    private let storageKey = "verse.interactions"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        entries = defaults.data(forKey: storageKey)
            .flatMap { try? JSONDecoder().decode([String: Entry].self, from: $0) } ?? [:]
        // Merge older translation-specific entries without discarding existing notes.
        for key in entries.keys.sorted() where key.contains(":") {
            guard let old = entries[key], let reference = key.split(separator: ":").last else { continue }
            let id = String(reference)
            var shared = entries[id] ?? Entry()
            shared.liked = shared.liked || old.liked
            if !old.note.isEmpty && shared.note != old.note {
                shared.note = shared.note.isEmpty ? old.note : shared.note + "\n\n" + old.note
            }
            entries[id] = shared
            entries.removeValue(forKey: key)
        }
        if let data = try? JSONEncoder().encode(entries) { defaults.set(data, forKey: storageKey) }

    }

    func entry(verseID: String, translationID: String) -> Entry {
        entries[verseID] ?? Entry()
    }

    func toggleLike(verseID: String, translationID: String) {
        var value = entry(verseID: verseID, translationID: translationID)
        value.liked.toggle()
        save(value, verseID: verseID, translationID: translationID)
    }

    func setNote(_ note: String, verseID: String, translationID: String) {
        var value = entry(verseID: verseID, translationID: translationID)
        value.note = note
        save(value, verseID: verseID, translationID: translationID)
    }

    private func save(_ value: Entry, verseID: String, translationID: String) {
        let key = verseID
        if !value.liked && value.note.isEmpty {
            entries.removeValue(forKey: key)
        } else {
            entries[key] = value
        }
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
