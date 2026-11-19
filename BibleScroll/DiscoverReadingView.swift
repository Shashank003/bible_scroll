import SwiftUI

struct DiscoverReadingView: View {
    let study: DiscoverStudy
    let library: BibleLibrary
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(study.theme).font(.system(.largeTitle, design: .serif))
                    Text(study.body).font(.system(.title3, design: .serif)).lineSpacing(7)
                    Text(study.attribution).font(.caption).foregroundStyle(.secondary)
                    Divider()
                    Text("Supporting Scripture").font(.headline)
                    ForEach(study.sources, id: \.self) { reference in
                        if let index = library.indexByID[reference] {
                            let verse = library.verses[index]
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(verse.reference) · \(library.translationID)")
                                    .font(.subheadline.weight(.semibold))
                                Text(verse.text).font(.system(.body, design: .serif)).lineSpacing(5)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppStyle.paper, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .textSelection(.enabled)
                .padding(24)
            }
            .background(AppStyle.backdrop)
            .navigationTitle(study.kind == .fact ? "Bible fact" : "Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
        .presentationDragIndicator(.visible)
    }
}
