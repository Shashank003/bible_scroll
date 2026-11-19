import SwiftUI

struct DailyReadingView: View {
    let library: BibleLibrary
    @EnvironmentObject private var store: ReadingPlanStore
    @EnvironmentObject private var chapters: ReadingProgress
    @State private var browsing = false
    @State private var completionCount = 0
    @State private var reading: PlanReadingSession?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Make space\nfor the Word.")
                                .font(.system(.largeTitle, design: .serif)).foregroundStyle(AppStyle.ink)
                            Text("A simple plan. One reading at a time.")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)
                        ReadingPlanHomeCard(bible: library,
                            openPlan: {
                                guard let plan = store.selected,
                                      let day = store.nextDay(for: plan),
                                      let first = plan.days[day].first else {
                                    browsing = true
                                    return
                                }
                                reading = PlanReadingSession(chapters: plan.days[day], startingAt: first.firstVerseID, planID: plan.id, day: day)
                            },
                            browse: { browsing = true })
                        if let plan = store.selected {
                            if let day = store.nextDay(for: plan) {
                                VStack(alignment: .leading, spacing: 18) {
                                    HStack {
                                        Text("Day \(day + 1)").font(.system(.title2, design: .serif))
                                        Spacer()
                                        Text("\(plan.days[day].count) \(plan.days[day].count == 1 ? "chapter" : "chapters")")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    ForEach(plan.days[day]) { chapter in
                                        Button {
                                            reading = PlanReadingSession(chapters: plan.days[day], startingAt: chapter.firstVerseID, planID: plan.id, day: day)
                                        } label: {
                                            HStack {
                                                Label(chapter.label(in: library), systemImage: "book")
                                                    .font(.subheadline)
                                                Spacer()
                                                Image(systemName: "arrow.up.right").font(.caption)
                                            }
                                            .frame(minHeight: 48)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    Button {
                                        for chapter in plan.days[day] {
                                            chapters.markDone(bookID: chapter.bookID, chapter: chapter.chapter)
                                        }
                                        store.markDone(day: day, in: plan)
                                        completionCount += 1
                                    } label: {
                                        Label("Mark this reading done", systemImage: "checkmark.circle")
                                            .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                                            .frame(maxWidth: .infinity, minHeight: 50)
                                            .background(AppStyle.button, in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    Text("Mark done after reading to move to the next assignment. You can read at your own pace.")
                                        .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
                                }
                                .homeCard()
                                .id("reading")
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "checkmark.circle.fill").font(.largeTitle).foregroundStyle(.green)
                                    Text("A path completed")
                                        .font(.system(.title2, design: .serif)).foregroundStyle(AppStyle.ink)
                                    Text("You have finished every reading in \(plan.title). Choose another plan whenever you are ready.")
                                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .homeCard()
                                .id("reading")
                            }
                        }
                    }
                    .padding(22).padding(.bottom, 20)
                }
                .background(AppStyle.backdrop)
            }
            .navigationTitle("Daily Reading")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $browsing) { BrowsePlansView(bible: library) }
            .sensoryFeedback(.success, trigger: completionCount)
            .fullScreenCover(item: $reading) { session in
                PlanReadingView(library: library, session: session)
            }
        }
        .tint(AppStyle.bronze)
    }
}
