import SwiftUI

struct HomeView: View {
    let library: BibleLibrary
    let openReader: (String) -> Void
    let openDailyReading: () -> Void
    @EnvironmentObject private var bookmarks: SavedVersesStore
    @EnvironmentObject private var interactions: VerseInteractions
    @EnvironmentObject private var progress: ReadingProgress
    @EnvironmentObject private var activity: ReadingActivity
    @EnvironmentObject private var devotionals: DevotionalStore
    @EnvironmentObject private var plans: ReadingPlanStore
    @AppStorage("kjv.readingReference") private var readingReference = "GEN.1.1"
    @State private var sheet: HomeSheet?
    @State private var showSettings = false
    @State private var showPlans = false
    @State private var planReading: PlanReadingSession?

    private var resumeVerse: Verse { library.verses[library.indexByID[readingReference] ?? 0] }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 60)) { time in
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header(date: time.date)
                        dailyVerse(date: time.date)
                        ReadingPlanHomeCard(bible: library, openPlan: {
                            guard let plan = plans.selected, let day = plans.nextDay(for: plan),
                                  let first = plan.days[day].first else {
                                openDailyReading()
                                return
                            }
                            planReading = PlanReadingSession(chapters: plan.days[day], startingAt: first.firstVerseID, planID: plan.id, day: day)
                        },
                                            browse: { showPlans = true })
                        HomeDevotionalCard(bible: library, date: time.date, store: devotionals,
                                           open: { sheet = .devotional($0) },
                                           openArchive: { sheet = .devotionalArchive })
                        VerseLookupCard(library: library, study: { sheet = .analysis($0) }, read: openReader)
                        continueReading
                        Button { sheet = .progress } label: {
                            progressCard
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
                .background(AppStyle.backdrop)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $sheet) { selection in
                switch selection {
                case .analysis(let verse): VerseAnalysisView(verse: verse, library: library)
                case .notes(let verse): VerseNotesView(verse: verse, translationID: library.translationID, interactions: interactions)
                case .devotional(let devotional):
                    NavigationStack {
                        DevotionalDetailView(devotional: devotional, bible: library, store: devotionals)
                    }
                    .tint(AppStyle.bronze)
                case .devotionalArchive:
                    DevotionalArchiveView(bible: library, store: devotionals).tint(AppStyle.bronze)
                case .progress: HomeProgressView(library: library)
                case .bookmarks:
                    SavedVersesView(library: library, store: bookmarks) { verse in
                        sheet = nil
                        openReader(verse.id)
                    }
                }
            }
            .navigationDestination(isPresented: $showPlans) { BrowsePlansView(bible: library) }
            .fullScreenCover(item: $planReading) { session in
                PlanReadingView(library: library, session: session)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(library: library)
            }
        }
    }

    private func header(date: Date) -> some View {
        let hour = Calendar.current.component(.hour, from: date)
        let greeting = hour < 12 ? "Good morning" : (hour < 17 ? "Good afternoon" : "Good evening")
        return VStack(alignment: .leading, spacing: 8) {
            Text(date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()).uppercased())
                .font(.caption2.weight(.medium)).tracking(1.5).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Text(greeting)
                    .font(.system(.title2, design: .serif).weight(.medium))
                    .foregroundStyle(AppStyle.ink)
                    .lineLimit(1).minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Button { sheet = .progress } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill").foregroundStyle(.orange)
                        Text("\(activity.streak(on: date))").monospacedDigit()
                    }
                    .font(.subheadline.weight(.semibold)).frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Reading activity, \(activity.streak(on: date)) day opening streak")
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape").frame(width: 44, height: 44)
                }
                .accessibilityLabel("Settings")
            }
            .buttonStyle(.plain)
        }
    }

    private func dailyVerse(date: Date) -> some View {
        let id = DailyVerse.reference(on: date, in: library)
        let verse = library.verses[library.indexByID[id] ?? 0]
        return VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 7) {
                    Label("VERSE OF THE DAY", systemImage: "sun.max")
                        .font(.caption2.weight(.semibold)).tracking(1.2).foregroundStyle(.secondary)
                    Button { openReader(verse.id) } label: {
                        Text(verse.reference).font(.headline)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Text(library.translationID)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .foregroundStyle(AppStyle.bronze)
                    .background(AppStyle.soft.opacity(0.6), in: Capsule())
            }
            Text(verse.text)
                .font(.system(.title2, design: .serif))
                .foregroundStyle(AppStyle.ink)
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .homeCard()
    }

    private var continueReading: some View {
        Button { openReader(resumeVerse.id) } label: {
            HStack(spacing: 16) {
                Image("AppLogo")
                    .resizable().scaledToFit().frame(width: 64, height: 64)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text("CONTINUE READING")
                        .font(.caption2.weight(.semibold)).tracking(1.2).foregroundStyle(.secondary)
                    Text(resumeVerse.reference).font(.system(.title3, design: .serif))
                    Text("Pick up where you left off")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.right").font(.subheadline.weight(.semibold))
            }
            .padding(20)
            .background(
                LinearGradient(colors: [AppStyle.soft, AppStyle.surface],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 26))
        }
        .buttonStyle(.plain)
    }

    private var progressCard: some View {
        let summary = BibleProgressSummary(library: library, completed: progress.completedChapters)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Your Bible journey").font(.system(.headline, design: .serif))
                Spacer()
                Text("\(summary.percent)%").font(.subheadline.weight(.semibold)).monospacedDigit()
            }
            ProgressView(value: summary.fraction).tint(.green)
            HStack {
                Text("\(summary.done) of \(summary.total) chapters")
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.caption).foregroundStyle(.secondary)
        }
        .homeCard()
    }
}

extension View {
    func homeCard() -> some View {
        padding(22)
            .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 26))
            .overlay(RoundedRectangle(cornerRadius: 26).stroke(AppStyle.border, lineWidth: 1))
            .shadow(color: AppStyle.shadow, radius: 16, y: 7)
    }
}

private enum HomeSheet: Identifiable {
    case analysis(Verse), notes(Verse), progress, bookmarks
    case devotional(Devotional), devotionalArchive
    var id: String {
        switch self {
        case .analysis(let verse): return "analysis.\(verse.id)"
        case .notes(let verse): return "notes.\(verse.id)"
        case .devotional(let devotional): return "devotional.\(devotional.id)"
        case .devotionalArchive: return "devotionalArchive"
        case .progress: return "progress"
        case .bookmarks: return "bookmarks"
        }
    }
}
