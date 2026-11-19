import Foundation

@main
struct VerseInteractionsTests {
    static func main() {
        let suite = "BibleScroll.InteractionsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = VerseInteractions(defaults: defaults)
        store.toggleLike(verseID: "GAL.2.8", translationID: "KJV")
        store.setNote("A personal reflection 🌿", verseID: "GAL.2.8", translationID: "KJV")
        precondition(store.entry(verseID: "GAL.2.8", translationID: "KJV").liked)
        precondition(!store.entry(verseID: "GAL.2.8", translationID: "NLT").liked)
        precondition(store.entry(verseID: "GAL.2.9", translationID: "KJV").note.isEmpty)
        store.setNote("Different translation note", verseID: "GAL.2.8", translationID: "NLT")
        let reopened = VerseInteractions(defaults: defaults)
        precondition(reopened.entry(verseID: "GAL.2.8", translationID: "KJV").note == "A personal reflection 🌿")
        precondition(reopened.entry(verseID: "GAL.2.8", translationID: "NLT").note == "Different translation note")
        reopened.setNote("", verseID: "GAL.2.8", translationID: "KJV")
        precondition(reopened.entry(verseID: "GAL.2.8", translationID: "KJV").liked)
        reopened.toggleLike(verseID: "GAL.2.8", translationID: "KJV")
        let final = VerseInteractions(defaults: defaults)
        precondition(!final.entry(verseID: "GAL.2.8", translationID: "KJV").liked)
        precondition(final.entry(verseID: "GAL.2.8", translationID: "KJV").note.isEmpty)
        precondition(final.entry(verseID: "GAL.2.8", translationID: "NLT").note == "Different translation note")
        print("Passed: likes, notes, persistence, verse/version isolation, clearing notes, unlike.")
    }
}
