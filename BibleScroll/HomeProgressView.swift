import SwiftUI

struct BibleProgressSummary {
    let total: Int
    let done: Int
    let booksDone: Int
    var fraction: Double { total == 0 ? 0 : Double(done) / Double(total) }
    var percent: Int { Int(fraction * 100) }

    init(library: BibleLibrary, completed: Set<String>) {
        var count = 0
        var finishedBooks = 0
        for book in library.books {
            let chapters = (1...book.chapters.count).filter { completed.contains("\(book.id).\($0)") }.count
            count += chapters
            if chapters == book.chapters.count { finishedBooks += 1 }
        }
        total = library.books.reduce(0) { $0 + $1.chapters.count }
        done = count
        booksDone = finishedBooks
    }
}

struct HomeProgressView: View {
    let library: BibleLibrary
    @EnvironmentObject private var progress: ReadingProgress
    @EnvironmentObject private var activity: ReadingActivity
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let summary = BibleProgressSummary(library: library, completed: progress.completedChapters)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("A little time,\none day at a time.")
                            .font(.system(.largeTitle, design: .serif))
                        Text("Each visit is a chance to pause and read.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 14) {
                        metric("Opening streak", value: "\(activity.streak()) days", icon: "flame.fill", color: AppStyle.bronze)
                        metric("Bible read", value: "\(summary.percent)%", icon: "book", color: .green)
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("This week").font(.headline)
                            Spacer()
                            Text("Best: \(activity.bestStreak()) days")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        week
                        Text("Opening streaks count days you open the app. Tracking started on this device; earlier visits are not reconstructed.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .homeCard()
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bible progress").font(.headline)
                        ProgressView(value: summary.fraction).tint(.green)
                        Text("\(summary.done) of \(summary.total) chapters · \(summary.booksDone) books complete")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text("Chapters count when you mark them done or swipe forward into the next chapter. Your progress carries across Bible versions.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .homeCard()
                }
                .padding(22)
            }
            .background(AppStyle.backdrop)
            .navigationTitle("Your progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var week: some View {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? calendar.startOfDay(for: .now)
        return HStack(spacing: 0) {
            ForEach(0..<7) { offset in
                let date = calendar.date(byAdding: .day, value: offset, to: start) ?? start
                let opened = activity.wasOpened(on: date)
                VStack(spacing: 10) {
                    Text(date.formatted(.dateTime.weekday(.narrow)))
                        .font(.caption).foregroundStyle(.secondary)
                    Text(date.formatted(.dateTime.day()))
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(opened ? Color.orange.opacity(0.15) : .clear, in: Circle())
                        .foregroundStyle(opened ? Color.primary : Color.secondary)
                    Circle().fill(opened ? Color.orange : .clear).frame(width: 4, height: 4)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(date.formatted(date: .complete, time: .omitted)), \(opened ? "opened" : "not opened")")
            }
        }
    }

    private func metric(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).foregroundStyle(color).font(.title2)
            Text(value).font(.system(.title2, design: .rounded).weight(.semibold))
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
    }
}
