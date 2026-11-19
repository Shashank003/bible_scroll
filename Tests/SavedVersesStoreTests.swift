import Foundation

@main
struct SavedVersesStoreTests {
    static func main() {
        let suite = "BibleScroll.SavedVersesTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = SavedVersesStore(defaults: defaults)
        precondition(store.verseIDs.isEmpty)
        store.toggle("GEN.1.1")
        store.toggle("JHN.1.1")
        precondition(store.verseIDs == ["JHN.1.1", "GEN.1.1"])

        let reopened = SavedVersesStore(defaults: defaults)
        precondition(reopened.contains("GEN.1.1"))
        precondition(reopened.verseIDs == store.verseIDs)
        reopened.toggle("GEN.1.1")
        precondition(!reopened.contains("GEN.1.1"))
        reopened.remove("JHN.1.1")
        reopened.remove("JHN.1.1")
        precondition(SavedVersesStore(defaults: defaults).verseIDs.isEmpty)

        defaults.set(["GEN.1.1", "GEN.1.1", "JHN.1.1"], forKey: "kjv.savedVerseIDs")
        precondition(SavedVersesStore(defaults: defaults).verseIDs == ["GEN.1.1", "JHN.1.1"])
        print("Passed: save, newest-first ordering, reopen, unsave, removal, duplicate recovery.")
    }
}
