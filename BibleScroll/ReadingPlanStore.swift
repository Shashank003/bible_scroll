import Combine
import Foundation

final class ReadingPlanStore: ObservableObject {
    @Published private(set) var plans: [ReadingPlan] = []
    @Published private(set) var selectedID: String?
    @Published private(set) var completedDays: [String: Set<Int>]
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        selectedID = defaults.string(forKey: "plans.selected")
        completedDays = defaults.data(forKey: "plans.completedDays")
            .flatMap { try? JSONDecoder().decode([String: Set<Int>].self, from: $0) } ?? [:]
    }

    var selected: ReadingPlan? { plans.first { $0.id == selectedID } }

    func load(from bible: BibleLibrary) { plans = ReadingPlan.catalog(in: bible) }

    func select(_ plan: ReadingPlan) {
        selectedID = plan.id
        defaults.set(plan.id, forKey: "plans.selected")
    }

    func completedCount(for plan: ReadingPlan) -> Int {
        (completedDays[plan.id] ?? []).filter { plan.days.indices.contains($0) }.count
    }

    func nextDay(for plan: ReadingPlan) -> Int? {
        plan.days.indices.first { !(completedDays[plan.id] ?? []).contains($0) }
    }

    func markDone(day: Int, in plan: ReadingPlan) {
        guard plan.days.indices.contains(day) else { return }
        var completed = completedDays[plan.id] ?? []
        guard completed.insert(day).inserted else { return }
        completedDays[plan.id] = completed
        if let data = try? JSONEncoder().encode(completedDays) {
            defaults.set(data, forKey: "plans.completedDays")
        }
    }
}
