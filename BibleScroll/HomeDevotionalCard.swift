import SwiftUI

struct HomeDevotionalCard: View {
    let bible: BibleLibrary
    let date: Date
    @ObservedObject var store: DevotionalStore
    let open: (Devotional) -> Void
    let openArchive: () -> Void

    var body: some View {
        if let devotional = store.featured(on: date) {
            let today = DevotionalLibrary.dateKey(date)
            let done = store.completed.contains(devotional.id)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("DAILY DEVOTIONAL")
                        .font(.caption2.weight(.semibold)).tracking(1.1)
                        .foregroundStyle(AppStyle.bronze)
                    Spacer(minLength: 4)
                    Button(action: openArchive) {
                        Label("Library", systemImage: "arrow.up.right")
                            .font(.caption.weight(.medium)).frame(minHeight: 44)
                    }
                }
                Button { open(devotional) } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        Image(devotional.artwork)
                            .resizable().scaledToFill()
                            .frame(height: 154).clipped()
                            .overlay(alignment: .bottom) {
                                LinearGradient(colors: [.clear, AppStyle.surface], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 54)
                            }
                            .overlay(alignment: .topTrailing) {
                                Text("\(devotional.readingMinutes(in: bible)) MIN")
                                    .font(.caption2.weight(.semibold)).tracking(1)
                                    .padding(.horizontal, 10).padding(.vertical, 7)
                                    .background(.regularMaterial, in: Capsule())
                                    .padding(14)
                            }
                        VStack(alignment: .leading, spacing: 13) {
                            Text("\(devotional.series.uppercased()) · DAY \(devotional.seriesDay)")
                                .font(.caption2.weight(.medium)).tracking(1.1)
                                .foregroundStyle(AppStyle.bronze)
                            Text(devotional.title)
                                .font(.system(.title2, design: .serif))
                                .foregroundStyle(AppStyle.ink)
                                .multilineTextAlignment(.leading)
                            Text(devotional.introduction)
                                .font(.subheadline).foregroundStyle(.secondary)
                                .lineSpacing(3).multilineTextAlignment(.leading)
                            Divider().overlay(AppStyle.border)
                            HStack {
                                if done {
                                    Label("Done", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                                } else {
                                    Text(devotional.date == today ? "A quiet moment for today" : devotional.displayDate)
                                }
                                Spacer(minLength: 8)
                                Text(done ? "Read again" : "Read devotional")
                                    .foregroundStyle(AppStyle.bronze)
                                Image(systemName: "arrow.right").foregroundStyle(AppStyle.bronze)
                            }
                            .font(.caption.weight(.medium)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 22).padding(.top, 8).padding(.bottom, 22)
                    }
                    .background(AppStyle.surface, in: RoundedRectangle(cornerRadius: 28))
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(AppStyle.border, lineWidth: 1))
                    .shadow(color: AppStyle.shadow, radius: 16, y: 7)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(done ? "Read again" : "Open devotional"): \(devotional.title), \(devotional.displayDate)")
            }
        } else {
            ContentUnavailableView("Devotionals unavailable", systemImage: "book.closed",
                                   description: Text("The devotional library could not be opened."))
                .homeCard()
        }
    }
}
