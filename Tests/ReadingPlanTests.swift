import Foundation

@main
struct ReadingPlanTests {
    static func main() throws {
        let bible = try BibleLibrary()
        let plans = ReadingPlan.catalog(in: bible)
        precondition(plans.count == 5)
        let durations = ["john-21": 21, "genesis-25": 25, "psalms-30": 30, "new-testament-90": 90, "bible-365": 365]
        let totals = ["john-21": 21, "genesis-25": 50, "psalms-30": 30, "new-testament-90": 260, "bible-365": 1189]
        for plan in plans {
            precondition(plan.days.count == durations[plan.id])
            precondition(plan.days.allSatisfy { !$0.isEmpty })
            let chapters = plan.days.flatMap { $0 }
            precondition(chapters.count == totals[plan.id])
            precondition(Set(chapters.map(\.id)).count == chapters.count)
            precondition(chapters.allSatisfy { bible.indexByID[$0.firstVerseID] != nil })
        }
        let allChapters = bible.books.flatMap { book in (1...book.chapters.count).map { "\(book.id).\($0)" } }
        precondition(plans.first { $0.id == "bible-365" }!.days.flatMap { $0 }.map(\.id) == allChapters)
        let ntChapters = bible.books.dropFirst(39).flatMap { book in (1...book.chapters.count).map { "\(book.id).\($0)" } }
        precondition(plans.first { $0.id == "new-testament-90" }!.days.flatMap { $0 }.map(\.id) == ntChapters)
        let suite = "BibleScroll.PlanTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ReadingPlanStore(defaults: defaults)
        store.load(from: bible)
        let john = plans.first { $0.id == "john-21" }!
        let genesis = plans.first { $0.id == "genesis-25" }!
        store.select(john)
        precondition(store.nextDay(for: john) == 0)
        store.markDone(day: 0, in: john)
        store.markDone(day: 0, in: john)
        store.markDone(day: -1, in: john)
        precondition(store.completedCount(for: john) == 1 && store.nextDay(for: john) == 1)
        store.select(genesis)
        precondition(store.completedCount(for: john) == 1 && store.completedCount(for: genesis) == 0)
        let reopened = ReadingPlanStore(defaults: defaults)
        reopened.load(from: bible)
        precondition(reopened.selected?.id == genesis.id)
        precondition(reopened.completedCount(for: john) == 1)
        reopened.select(john)
        for day in john.days.indices { reopened.markDone(day: day, in: john) }
        precondition(reopened.nextDay(for: john) == nil)
        precondition(reopened.completedCount(for: john) == 21)
        print("Passed: 5 complete schedules, exact chapter coverage, valid references, selection persistence, progress isolation, switching, duplicate protection, and plan completion.")
    }
}
