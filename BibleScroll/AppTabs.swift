import SwiftUI

struct AppTabs: View {
    @State private var selectedTab = 0
    @AppStorage("bible.translation") private var translationID = "KJV"
    @State private var requestedVerseID: String?
    @Environment(\.scenePhase) private var scenePhase
    @State private var library: BibleLibrary?
    @State private var loadFailed = false
    @StateObject private var bookmarks = SavedVersesStore()
    @StateObject private var interactions = VerseInteractions()
    @StateObject private var readingProgress = ReadingProgress()
    @StateObject private var activity = ReadingActivity()
    @StateObject private var devotionals = DevotionalStore()
    @StateObject private var plans = ReadingPlanStore()

    var body: some View {
        Group {
            if let library {
                TabView(selection: $selectedTab) {
                    HomeView(library: library, openReader: { reference in
                        requestedVerseID = reference
                        selectedTab = 1
                    }, openDailyReading: { selectedTab = 3 })
                    .tabItem {
                        Label { Text("Home") } icon: { Image(uiImage: CuteTabIcons.home) }
                    }
                    .tag(0)

                    DiscoverView(library: library)
                        .tabItem { Label("Discover", systemImage: "sparkles") }
                        .tag(2)

                    DailyReadingView(library: library)
                        .tabItem { Label("Daily Reading", systemImage: "calendar") }
                        .tag(3)

                    BibleReaderView(library: library, requestedVerseID: $requestedVerseID)
                        .id(library.translationID)
                        .tabItem {
                            Label { Text("The Bible") } icon: { Image(uiImage: CuteTabIcons.bible) }
                        }
                        .tag(1)
                }
            } else if loadFailed {
                ContentUnavailableView("Unable to open the Bible", systemImage: "book.closed",
                    description: Text("The bundled text could not be loaded. Please rebuild or reinstall the app."))
            } else {
                ProgressView("Opening your Bible…")
            }
        }
        .environmentObject(bookmarks)
        .environmentObject(interactions)
        .environmentObject(readingProgress)
        .environmentObject(activity)
        .environmentObject(devotionals)
        .environmentObject(plans)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { activity.recordOpen() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            if scenePhase == .active { activity.recordOpen() }
        }
        .tint(AppStyle.bronze)
        .task(id: translationID) {
            activity.recordOpen()
            let selectedTranslation = translationID
            do {
                let loaded = try await Task.detached(priority: .userInitiated) { try BibleLibrary(translationID: selectedTranslation) }.value
                guard !Task.isCancelled else { return }
                plans.load(from: loaded)
                library = loaded
            } catch { loadFailed = true }
        }
    }
}
