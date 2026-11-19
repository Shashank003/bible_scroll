import SwiftUI

struct PlanReadingSession: Identifiable {
    let id = UUID()
    let chapters: [PlanChapter]
    let startingAt: String
    let planID: String
    let day: Int
}

/// A bounded plan reader with its own position; never changes the Bible tab's location.
struct PlanReadingView: View {
    let library: BibleLibrary
    let session: PlanReadingSession
    private let verses: [Verse]
    @State private var index: Int
    @State private var analysis: Verse?
    @State private var notes: Verse?
    @AppStorage("reader.fontSize") private var fontSize = 30.0
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bookmarks: SavedVersesStore
    @EnvironmentObject private var interactions: VerseInteractions
    @EnvironmentObject private var plans: ReadingPlanStore
    @EnvironmentObject private var progress: ReadingProgress
    @State private var completed = false

    init(library: BibleLibrary, session: PlanReadingSession) {
        self.library = library
        self.session = session
        let chapters = Set(session.chapters.map(\.id))
        let readings = library.verses.filter { chapters.contains("\($0.bookID).\($0.chapter)") }
        verses = readings
        _index = State(initialValue: readings.firstIndex { $0.id == session.startingAt } ?? 0)
    }

    var body: some View {
        NavigationStack {
            if !verses.isEmpty {
                VersePager(count: verses.count + 1, index: $index,
                           revision: "\(fontSize)|\(bookmarks.verseIDs.joined(separator: ","))") { position in
                    return Group {
                        if position == verses.count {
                            PlanReadingCompletionView(day: session.day, close: { dismiss() })
                        } else {
                            let verse = verses[position]
                            VersePage(verse: verse, fontSize: fontSize, isLast: position == verses.count - 1,
                              isSaved: bookmarks.contains(verse.id),
                              toggleSave: { bookmarks.toggle(verse.id) },
                              openAnalysis: { analysis = verse }, translationID: library.translationID,
                              interactions: interactions, openNotes: { notes = verse },
                              endMessage: "Swipe up to finish today’s reading", verticalPadding: 20)
                        }
                    }
                }
                .onChange(of: index) { _, position in
                    guard position == verses.count, !completed,
                          let plan = plans.plans.first(where: { $0.id == session.planID }) else { return }
                    plans.markDone(day: session.day, in: plan)
                    for chapter in session.chapters {
                        progress.markDone(bookID: chapter.bookID, chapter: chapter.chapter)
                    }
                    completed = true
                }
                .sensoryFeedback(.success, trigger: completed)
                .overlay(alignment: .leading) {
                    if index < verses.count {
                        ChapterProgressIndicator(verse: index + 1, total: verses.count, scope: "daily reading") { number in
                            index = number - 1
                        }
                        .frame(width: 44)
                        .padding(.vertical, 20)
                    }
                }
                .navigationTitle(index == verses.count ? "Well done" : verses[index].reference)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                }
            }
        }
        .background(AppStyle.backdrop)
        .tint(AppStyle.bronze)
        .sheet(item: $analysis) { VerseAnalysisView(verse: $0, library: library) }
        .sheet(item: $notes) { VerseNotesView(verse: $0, translationID: library.translationID, interactions: interactions) }
    }

}

private struct PlanReadingCompletionView: View {
    let day: Int
    let close: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var celebrate = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(.green.opacity(0.07)).frame(width: 220, height: 220)
                    .scaleEffect(celebrate ? 1 : 0.6)
                Circle().stroke(.green.opacity(0.18), lineWidth: 1).frame(width: 175, height: 175)
                    .scaleEffect(celebrate ? 1 : 0.7)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80, weight: .light)).foregroundStyle(.green)
                    .scaleEffect(celebrate ? 1 : 0.5)
                    .rotationEffect(.degrees(celebrate || reduceMotion ? 0 : -15))
            }
            Text("A little closer,\none day at a time.")
                .font(.system(.largeTitle, design: .serif)).multilineTextAlignment(.center)
                .foregroundStyle(AppStyle.ink)
            Text("Day \(day + 1) is complete.\nYour reading progress has been saved.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).lineSpacing(5)
            Button(action: close) {
                Text("Return to plan").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(AppStyle.button, in: Capsule())
            }
            .buttonStyle(.plain).padding(.top, 12)
            Spacer()
        }
        .padding(32).frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppStyle.backdrop)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.8, bounce: 0.25)) {
                celebrate = true
            }
        }
    }
}
