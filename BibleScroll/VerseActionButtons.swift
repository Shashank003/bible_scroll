import SwiftUI

struct VerseActionButtons: View {
    let verse: Verse
    let translationID: String
    @ObservedObject var interactions: VerseInteractions
    let openNotes: () -> Void

    private var entry: VerseInteractions.Entry {
        interactions.entry(verseID: verse.id, translationID: translationID)
    }

    var body: some View {
        HStack(spacing: 10) {
            Button {
                interactions.toggleLike(verseID: verse.id, translationID: translationID)
            } label: {
                icon(entry.liked ? "heart.fill" : "heart", color: entry.liked ? .pink : AppStyle.ink)
            }
            .accessibilityLabel(entry.liked ? "Unlike \(verse.reference)" : "Like \(verse.reference)")
            .accessibilityValue(entry.liked ? "Liked" : "Not liked")

            Button(action: openNotes) {
                icon("pencil.line", color: entry.note.isEmpty ? AppStyle.ink : AppStyle.bronze)
                    .overlay(alignment: .topTrailing) {
                        if !entry.note.isEmpty {
                            Circle().fill(AppStyle.bronze).frame(width: 7, height: 7).padding(5)
                        }
                    }
            }
            .accessibilityLabel(entry.note.isEmpty ? "Add note" : "Edit note")

            ShareLink(item: "\(verse.text)\n— \(verse.reference) (\(translationID))") {
                icon("square.and.arrow.up", color: AppStyle.ink)
            }
            .accessibilityLabel("Share \(verse.reference), \(translationID)")
        }
        .buttonStyle(.plain)
    }

    private func icon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(color)
            .frame(width: 46, height: 46)
            .background(AppStyle.paper, in: Circle())
            .overlay(Circle().stroke(AppStyle.border, lineWidth: 1))
            .shadow(color: AppStyle.shadow.opacity(0.5), radius: 6, y: 3)
    }
}
