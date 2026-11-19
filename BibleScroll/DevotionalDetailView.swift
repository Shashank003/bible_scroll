import SwiftUI

struct DevotionalDetailView: View {
    let devotional: Devotional
    let bible: BibleLibrary
    @ObservedObject var store: DevotionalStore
    @Environment(\.dismiss) private var dismiss
    @State private var reading = false

    private var done: Bool { store.completed.contains(devotional.id) }
    private var savedStep: String? { store.position(for: devotional, translation: bible.translationID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Image(devotional.artwork)
                    .resizable().scaledToFill()
                    .frame(height: 250).clipped()
                    .overlay(alignment: .bottom) {
                        LinearGradient(colors: [.clear, AppStyle.canvas], startPoint: .top, endPoint: .bottom)
                            .frame(height: 100)
                    }
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DAILY DEVOTIONAL · \(devotional.displayDate.uppercased())")
                            .font(.caption2.weight(.medium)).tracking(1.2).foregroundStyle(AppStyle.bronze)
                        Text(devotional.title)
                            .font(.system(.largeTitle, design: .serif))
                            .foregroundStyle(AppStyle.ink)
                        Text("\(devotional.series) · Day \(devotional.seriesDay)")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Label("\(devotional.readingMinutes(in: bible)) minute reading · \(bible.translationID)", systemImage: "clock")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Text(devotional.introduction)
                        .font(.system(.title3, design: .serif)).lineSpacing(6)
                        .foregroundStyle(AppStyle.ink)
                    if done {
                        Label("You finished this devotional", systemImage: "checkmark.circle.fill")
                            .font(.subheadline).foregroundStyle(.green)
                    }
                    Button {
                        if done { store.savePosition("intro", devotional: devotional, translation: bible.translationID) }
                        reading = true
                    } label: {
                        HStack(spacing: 10) {
                            Text(done ? "Read again" : (savedStep != nil && savedStep != "intro" ? "Continue reading" : "Begin devotional"))
                            Image(systemName: "arrow.right")
                        }
                        .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(AppStyle.button, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Inside this reading").font(.system(.title3, design: .serif))
                        routeRow("Read", subtitle: "Scripture, in its own words", icon: "book")
                        routeRow("Reflect", subtitle: "A little space to consider the passage", icon: "sparkles")
                        routeRow("Respond", subtitle: "One practice and a short prayer", icon: "leaf")
                    }
                    .homeCard()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SCRIPTURE FOR THIS READING")
                            .font(.caption2.weight(.semibold)).tracking(1.1).foregroundStyle(AppStyle.bronze)
                        Text(devotional.passageLabel(in: bible))
                            .font(.system(.subheadline, design: .serif)).foregroundStyle(.secondary)
                    }
                    Text(devotional.author).font(.caption2).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .background(AppStyle.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: { Image(systemName: "xmark") }
                    .accessibilityLabel("Close devotional")
            }
            ToolbarItem(placement: .primaryAction) {
                Button { store.toggleBookmark(devotional) } label: {
                    Image(systemName: store.bookmarks.contains(devotional.id) ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(store.bookmarks.contains(devotional.id) ? "Remove devotional bookmark" : "Bookmark devotional")
            }
        }
        .fullScreenCover(isPresented: $reading) {
            DevotionalReaderView(devotional: devotional, bible: bible, store: store)
        }
    }

    private func routeRow(_ title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(AppStyle.bronze).frame(width: 26)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.medium))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
