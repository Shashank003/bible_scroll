import SwiftUI

struct BrowsePlansView: View {
    let bible: BibleLibrary
    @EnvironmentObject private var store: ReadingPlanStore
    @Environment(\.dismiss) private var dismiss
    @State private var schedule: ReadingPlan?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("A little reading,\nevery day.")
                        .font(.system(.largeTitle, design: .serif)).foregroundStyle(AppStyle.ink)
                    Text("Choose a guided path through Scripture. Your progress is saved, so you can switch plans without starting over.")
                        .font(.subheadline).foregroundStyle(.secondary).lineSpacing(4)
                }
                .padding(.vertical, 8)
                ForEach(store.plans) { plan in
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top, spacing: 16) {
                            Image(plan.artwork).resizable().scaledToFill()
                                .frame(width: 72, height: 84).clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(plan.title).font(.system(.title2, design: .serif)).foregroundStyle(AppStyle.ink)
                                Text(plan.subtitle).font(.caption).foregroundStyle(.secondary)
                                Label("\(plan.days.count) days · At your pace", systemImage: "calendar")
                                    .font(.caption2.weight(.medium)).foregroundStyle(AppStyle.bronze)
                                Label("About \(plan.estimatedMinutesPerDay) min / day", systemImage: "clock")
                                    .font(.caption.weight(.medium)).foregroundStyle(AppStyle.bronze)
                            }
                            Spacer(minLength: 0)
                        }
                        Text(plan.description).font(.subheadline).foregroundStyle(.secondary).lineSpacing(4)
                        if store.completedCount(for: plan) > 0 {
                            Text("\(store.completedCount(for: plan)) of \(plan.days.count) readings complete")
                                .font(.caption).foregroundStyle(AppStyle.bronze)
                        }
                        HStack(spacing: 12) {
                            Button { schedule = plan } label: {
                                Text("View readings").font(.caption.weight(.medium)).frame(minHeight: 48)
                            }
                            Spacer(minLength: 8)
                            Button {
                                store.select(plan)
                                dismiss()
                            } label: {
                                Label(store.selectedID == plan.id ? "Selected" : (store.completedCount(for: plan) > 0 ? "Resume plan" : "Choose plan"),
                                      systemImage: store.selectedID == plan.id ? "checkmark" : "arrow.right")
                                    .font(.caption.weight(.semibold)).foregroundStyle(.white)
                                    .padding(.horizontal, 18).frame(minHeight: 48)
                                    .background(AppStyle.button, in: Capsule())
                            }
                            .disabled(store.selectedID == plan.id)
                        }
                        .buttonStyle(.plain)
                    }
                    .homeCard()
                }
                Text("Reading times are estimates at 180 words per minute. Take extra time to pause and reflect.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(22)
        }
        .background(AppStyle.backdrop)
        .navigationTitle("Browse plans")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .sheet(item: $schedule) { plan in
            NavigationStack {
                List(plan.days.indices, id: \.self) { day in
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Day \(day + 1)").font(.subheadline.weight(.semibold))
                        Label("About \(plan.dailyMinutes[day]) min", systemImage: "clock")
                            .font(.caption).foregroundStyle(AppStyle.bronze)
                        Text(plan.readingLabel(day: day, in: bible))
                            .font(.system(.body, design: .serif)).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(AppStyle.surface)
                }
                .scrollContentBackground(.hidden)
                .background(AppStyle.canvas)
                .navigationTitle(plan.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { schedule = nil } } }
            }
            .tint(AppStyle.bronze)
        }
    }
}
