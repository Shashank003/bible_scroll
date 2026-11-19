import SwiftUI

struct DevotionalReaderView: View {
    let devotional: Devotional
    let bible: BibleLibrary
    @ObservedObject var store: DevotionalStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var finished = false
    @State private var restored = false

    private var steps: [DevotionalReadingStep] { DevotionalReadingStep.make(devotional: devotional, bible: bible) }

    var body: some View {
        let pages = steps
        NavigationStack {
            VStack(spacing: 0) {
                if finished {
                    completion
                } else {
                    VersePager(count: pages.count, index: $page, revision: bible.translationID) { index in
                        DevotionalPage(step: pages[index], artwork: devotional.artwork)
                    }
                    .clipped()
                    footer(pages: pages)
                }
            }
            .background(AppStyle.backdrop)
            .navigationTitle(bible.translationID)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel("Close devotional reading")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { store.toggleBookmark(devotional) } label: {
                        Image(systemName: store.bookmarks.contains(devotional.id) ? "bookmark.fill" : "bookmark")
                    }
                    .accessibilityLabel("Bookmark devotional")
                }
            }
            .onAppear {
                guard !restored else { return }
                let saved = store.position(for: devotional, translation: bible.translationID)
                page = pages.firstIndex(where: { $0.id == saved }) ?? 0
                restored = true
            }
            .onChange(of: page) { _, index in
                store.savePosition(pages[index].id, devotional: devotional, translation: bible.translationID)
            }
            .sensoryFeedback(.success, trigger: finished)
        }
        .tint(AppStyle.bronze)
    }

    private func footer(pages: [DevotionalReadingStep]) -> some View {
        VStack(spacing: 16) {
            ProgressView(value: Double(page + 1), total: Double(pages.count)).tint(AppStyle.bronze)
            HStack(spacing: 16) {
                Button { page = max(0, page - 1) } label: {
                    Image(systemName: "arrow.left").frame(width: 44, height: 48)
                }
                .disabled(page == 0)
                .accessibilityLabel("Previous page")
                if page == pages.count - 1 {
                    Button {
                        store.finish(devotional)
                        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.4)) { finished = true }
                    } label: {
                        Text("Finish devotional")
                            .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(AppStyle.button, in: Capsule())
                    }
                } else {
                    Text("\(page + 1) of \(pages.count)")
                        .font(.caption).monospacedDigit().foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    Button { page = min(pages.count - 1, page + 1) } label: {
                        Image(systemName: "arrow.right")
                            .frame(width: 48, height: 48)
                            .background(AppStyle.soft.opacity(0.7), in: Circle())
                    }
                    .accessibilityLabel("Next page")
                }
            }
            Text("Swipe up to continue, down to go back")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 16)
    }

    private var completion: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.green)
                .frame(width: 100, height: 100)
                .background(AppStyle.paper, in: Circle())
            Text("Devotional complete")
                .font(.system(.largeTitle, design: .serif)).multilineTextAlignment(.center)
                .foregroundStyle(AppStyle.ink)
            Text("This devotional is marked as read. Carry its practice with you today.")
                .font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).lineSpacing(5)
            Spacer()
            Button("Read again") {
                page = 0
                store.savePosition("intro", devotional: devotional, translation: bible.translationID)
                finished = false
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 44)
            Button("Return to devotional") { dismiss() }
                .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(AppStyle.button, in: Capsule())
        }
        .padding(28)
        .transition(.opacity)
    }
}

private struct DevotionalPage: View {
    let step: DevotionalReadingStep
    let artwork: String

    var body: some View {
        GeometryReader { area in
            ViewThatFits(in: .vertical) {
                content(showArtwork: area.size.height > 420)
                    .fixedSize(horizontal: false, vertical: true)
                ScrollView { content(showArtwork: false).padding(.vertical, 16) }
            }
            .frame(width: area.size.width, height: area.size.height)
            .clipped()
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
    }

    private func content(showArtwork: Bool) -> some View {
        VStack(spacing: 22) {
            if step.kind == .introduction && showArtwork {
                Image(artwork).resizable().scaledToFill()
                    .frame(height: 150).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .accessibilityHidden(true)
            }
            Text(step.caption.uppercased())
                .font(.caption2.weight(.medium)).tracking(1.4)
                .foregroundStyle(AppStyle.bronze).multilineTextAlignment(.center)
            Text(step.heading)
                .font(.system(.title, design: .serif))
                .foregroundStyle(AppStyle.ink).multilineTextAlignment(.center)
            Rectangle().fill(AppStyle.border).frame(width: 40, height: 1)
            Text(step.text)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(AppStyle.ink)
                .lineSpacing(8)
                .multilineTextAlignment(step.kind == .reflection ? .leading : .center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity)
    }
}
