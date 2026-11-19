import SwiftUI

struct DevotionalArchiveView: View {
    let bible: BibleLibrary
    @ObservedObject var store: DevotionalStore
    @Environment(\.dismiss) private var dismiss
    @State private var savedOnly = false

    private var entries: [Devotional] {
        (store.library?.entries ?? []).filter { !savedOnly || store.bookmarks.contains($0.id) }
    }
    private var months: [String] { Array(Set(entries.map { String($0.date.prefix(7)) })).sorted() }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView("No saved devotionals", systemImage: "bookmark",
                                           description: Text("Bookmark a devotional to keep it here."))
                } else {
                    List {
                        ForEach(months, id: \.self) { month in
                            Section(monthName(month)) {
                                ForEach(entries.filter { $0.date.hasPrefix(month) }) { devotional in
                                    HStack(spacing: 12) {
                                        NavigationLink {
                                            DevotionalDetailView(devotional: devotional, bible: bible, store: store)
                                        } label: {
                                            HStack(spacing: 14) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 14).fill(AppStyle.soft.opacity(0.65))
                                                    Text(String(devotional.seriesDay)).font(.system(.title3, design: .serif))
                                                }
                                                .frame(width: 46, height: 52)
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Text(devotional.title).font(.system(.subheadline, design: .serif))
                                                    Text(devotional.displayDate)
                                                        .font(.caption2).foregroundStyle(.secondary)
                                                }
                                                Spacer(minLength: 0)
                                                if store.completed.contains(devotional.id) {
                                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                                }
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        Button { store.toggleBookmark(devotional) } label: {
                                            Image(systemName: store.bookmarks.contains(devotional.id) ? "bookmark.fill" : "bookmark")
                                                .frame(width: 32, height: 44)
                                        }
                                        .buttonStyle(.borderless)
                                        .accessibilityLabel("\(store.bookmarks.contains(devotional.id) ? "Remove bookmark for" : "Bookmark") \(devotional.title)")
                                    }
                                    .listRowBackground(AppStyle.surface)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppStyle.canvas)
            .navigationTitle(savedOnly ? "Saved devotionals" : "Devotional library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button { savedOnly.toggle() } label: {
                        Image(systemName: savedOnly ? "bookmark.fill" : "bookmark")
                    }
                    .accessibilityLabel(savedOnly ? "Show all devotionals" : "Show bookmarked devotionals")
                }
            }
        }
    }

    private func monthName(_ key: String) -> String {
        if key == "2026-12" { return "December 2026" }
        if key == "2027-01" { return "January 2027" }
        return key
    }
}
