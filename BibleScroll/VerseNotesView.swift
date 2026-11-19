import SwiftUI

struct VerseNotesView: View {
    let verse: Verse
    let translationID: String
    @ObservedObject var interactions: VerseInteractions
    @Environment(\.dismiss) private var dismiss
    @FocusState private var editing: Bool

    private var note: Binding<String> {
        Binding(get: { interactions.entry(verseID: verse.id, translationID: translationID).note },
                set: { interactions.setNote($0, verseID: verse.id, translationID: translationID) })
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 10) {
                    Text(verse.reference).font(.system(.title2, design: .serif).weight(.medium))
                    Text(translationID).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    ScrollView {
                        Text(verse.text)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxHeight: 110)
                }
                .frame(maxWidth: .infinity)
                Divider()
                HStack {
                    Label("Your notes", systemImage: "pencil.line").font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("Saved on this iPhone").font(.caption).foregroundStyle(.secondary)
                }
                TextEditor(text: note)
                    .focused($editing)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 22))
                    .accessibilityLabel("Notes for \(verse.reference), \(translationID)")
                if !note.wrappedValue.isEmpty {
                    Button("Delete note", role: .destructive) { note.wrappedValue = "" }
                        .font(.subheadline)
                }
            }
            .padding(22)
            .background(AppStyle.backdrop)
            .navigationTitle("Personal notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .tint(AppStyle.bronze)
        .presentationDragIndicator(.visible)
        .onAppear { editing = true }
    }
}
