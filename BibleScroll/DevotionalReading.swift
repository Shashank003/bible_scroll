import Foundation

struct DevotionalReadingStep: Identifiable {
    enum Kind { case introduction, scripture, reflection, application, prayer, finish }
    let id: String
    let kind: Kind
    let heading: String
    let caption: String
    let text: String

    static func make(devotional: Devotional, bible: BibleLibrary) -> [DevotionalReadingStep] {
        var steps = [DevotionalReadingStep(id: "intro", kind: .introduction, heading: devotional.title,
                                          caption: "\(devotional.series) · Day \(devotional.seriesDay)",
                                          text: devotional.introduction)]
        for reference in devotional.scriptureReferences {
            guard let index = bible.indexByID[reference] else { continue }
            let verse = bible.verses[index]
            for (part, text) in VersePagination.sections(verse.text, maxWords: 65, fits: { _ in true }).enumerated() {
                steps.append(.init(id: "scripture-\(reference)-\(part)", kind: .scripture,
                                   heading: verse.reference, caption: bible.translationID, text: text))
            }
        }
        for (part, text) in VersePagination.sections(devotional.reflection, maxWords: 65, fits: { _ in true }).enumerated() {
            steps.append(.init(id: "reflection-\(part)", kind: .reflection,
                               heading: "A moment to reflect", caption: "REFLECTION", text: text))
        }
        steps.append(.init(id: "application", kind: .application, heading: "Carry it into your day",
                           caption: "ONE SMALL PRACTICE", text: devotional.application))
        steps.append(.init(id: "prayer", kind: .prayer, heading: "A quiet prayer",
                           caption: "PAUSE & PRAY", text: devotional.prayer))
        steps.append(.init(id: "finish", kind: .finish, heading: "Keep a little stillness",
                           caption: "READ · REFLECT · RESPOND",
                           text: "You have made room for Scripture, reflection, and prayer. Take one small response with you as you return to your day."))
        return steps
    }
}
