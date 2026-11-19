import Foundation

enum VersePagination {
    /// Preserve every word in order, splitting at word boundaries and fitting
    /// both the word limit and the available reading space.
    static func sections(_ text: String, maxWords: Int = 45,
                         fits: (String) -> Bool) -> [String] {
        precondition(maxWords > 0)
        let words = text.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        var result: [String] = []
        var current: [String] = []
        for word in words {
            let candidate = current + [word]
            if !current.isEmpty && (candidate.count > maxWords || !fits(candidate.joined(separator: " "))) {
                result.append(current.joined(separator: " "))
                current = [word]
            } else {
                current = candidate
            }
        }
        if !current.isEmpty { result.append(current.joined(separator: " ")) }
        return result.isEmpty ? [""] : result
    }
}
