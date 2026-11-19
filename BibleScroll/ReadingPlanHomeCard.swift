import SwiftUI

struct ReadingPlanHomeCard: View {
    let bible: BibleLibrary
    let openPlan: () -> Void
    let browse: () -> Void
    @EnvironmentObject private var store: ReadingPlanStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: store.selected == nil ? browse : openPlan) {
                HStack(spacing: 16) {
                    Image(store.selected?.artwork ?? "DevotionalJanuary")
                        .resizable().scaledToFill().frame(width: 78, height: 90).clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TODAY’S READING")
                            .font(.caption2.weight(.semibold)).tracking(1.2).foregroundStyle(AppStyle.bronze)
                        if let plan = store.selected {
                            Text(plan.title).font(.system(.title3, design: .serif)).foregroundStyle(AppStyle.ink)
                            if let day = store.nextDay(for: plan) {
                                Text(plan.readingLabel(day: day, in: bible)).font(.caption).foregroundStyle(.secondary)
                                Text("Day \(day + 1) of \(plan.days.count)")
                                    .font(.caption2).foregroundStyle(.secondary)
                                Label("About \(plan.dailyMinutes[day]) min today", systemImage: "clock")
                                    .font(.caption2.weight(.medium)).foregroundStyle(AppStyle.bronze)
                            } else {
                                Label("Plan complete", systemImage: "checkmark.circle.fill")
                                    .font(.caption).foregroundStyle(.green)
                            }
                        } else {
                            Text("Find your reading rhythm")
                                .font(.system(.title3, design: .serif)).foregroundStyle(AppStyle.ink)
                            Text("A chapter a day, or the whole story. Choose a path that fits your life.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(AppStyle.bronze)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if let plan = store.selected {
                ProgressView(value: Double(store.completedCount(for: plan)), total: Double(plan.days.count))
                    .tint(AppStyle.bronze)
            }
            Button(action: browse) {
                HStack {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse plans")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppStyle.bronze)
                .padding(.horizontal, 16).frame(minHeight: 46)
                .background(AppStyle.soft.opacity(0.5), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .homeCard()
    }
}
