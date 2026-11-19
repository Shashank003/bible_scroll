import SwiftUI
import UIKit

struct ChapterProgressIndicator: View {
    let verse: Int
    let total: Int
    var scope = "chapter"
    let selectVerse: (Int) -> Void
    @State private var dragging = false
    @State private var lastSelection: Int?
    @State private var feedback = UISelectionFeedbackGenerator()

    private var remaining: Int { max(0, total - verse) }

    var body: some View {
        VStack(spacing: 12) {
            Text("\(verse)/\(total)")
                .font(.system(size: 10, weight: .medium).monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Drawing the rail avoids adding a view for every verse.
            GeometryReader { track in
            Canvas { context, size in
                guard total > 0 else { return }
                let gap = min(3, size.height / CGFloat(total * 3))
                let height = max(0, (size.height - gap * CGFloat(total - 1)) / CGFloat(total))
                for index in 0..<total {
                    let rect = CGRect(x: 7,
                                      y: CGFloat(index) * (height + gap), width: 3, height: height)
                    let color: Color = index == verse - 1 ? .primary : .secondary.opacity(index < verse - 1 ? 0.45 : 0.15)
                    context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(color))
                }
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !dragging { feedback.prepare() }
                    dragging = true
                    let selected = ChapterRailPosition.verse(at: value.location.y,
                                                            height: track.size.height, total: total)
                    guard selected != lastSelection else { return }
                    lastSelection = selected
                    if selected != verse {
                        feedback.selectionChanged()
                        selectVerse(selected)
                    }
                }
                .onEnded { _ in
                    dragging = false
                    lastSelection = nil
                })
            }

            VStack(spacing: 2) {
                Text("\(remaining)")
                    .font(.system(size: 12, weight: .semibold).monospacedDigit())
                Text("left")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .background(dragging ? Color.primary.opacity(0.035) : .clear,
                    in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(scope.capitalized) progress")
        .accessibilityValue("Verse \(verse) of \(total). \(remaining) upward swipes left in this \(scope).")
        .accessibilityHint("Drag along the rail to choose a verse in this \(scope).")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selectVerse(min(total, verse + 1))
            case .decrement: selectVerse(max(1, verse - 1))
            @unknown default: break
            }
        }
    }
}
