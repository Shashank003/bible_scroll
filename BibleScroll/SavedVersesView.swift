import SwiftUI

struct SavedVersesView: View {
    let library: BibleLibrary
    @ObservedObject var store: SavedVersesStore
    let select: (Verse) -> Void
    @Environment(\.dismiss) private var dismiss

    private var verses: [Verse] {
        store.verseIDs.compactMap { id in
            library.indexByID[id].map { library.verses[$0] }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if verses.isEmpty {
                    ContentUnavailableView("No bookmarks yet", systemImage: "bookmark",
                        description: Text("Tap Bookmark beneath a passage to keep it here."))
                } else {
                    List {
                        Section {
                            ForEach(verses) { verse in
                                Button { select(verse) } label: {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(verse.reference)
                                            .font(.headline)
                                        Text(verse.text)
                                            .font(.system(.body, design: .serif))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(3)
                                    }
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityHint("Opens this verse in the Bible reader")
                                .swipeActions {
                                    Button("Remove", role: .destructive) { store.remove(verse.id) }
                                }
                                .contextMenu {
                                    Button("Remove bookmark", systemImage: "bookmark.slash", role: .destructive) {
                                        store.remove(verse.id)
                                    }
                                }
                                .accessibilityAction(named: "Remove bookmark") { store.remove(verse.id) }
                            }
                        } header: {
                            Text("Most recently bookmarked first")
                        } footer: {
                            Text("Tap a verse to read it. Swipe left to remove it from this list.")
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppStyle.canvas)
                }
            }
            .background(AppStyle.canvas)
            .navigationTitle("Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}
