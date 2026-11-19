import Foundation

enum ChapterRailPosition {
    static func verse(at position: CGFloat, height: CGFloat, total: Int) -> Int {
        guard total > 0, height > 0 else { return 1 }
        let fraction = min(1, max(0, position / height))
        return min(total, Int(fraction * CGFloat(total)) + 1)
    }
}
