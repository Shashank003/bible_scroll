import Foundation

@main
struct VersePaginationTests {
    static func main() throws {
        let url = URL(fileURLWithPath: CommandLine.arguments[1])
        let books = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [[String: Any]]
        var count = 0
        for book in books {
            for chapter in book["chapters"] as! [[String]] {
                for verse in chapter {
                    let parts = VersePagination.sections(verse) { $0.count <= 150 }
                    precondition(parts.joined(separator: " ") == verse)
                    precondition(parts.allSatisfy { !$0.isEmpty && $0.split(separator: " ").count <= 45 })
                    precondition(parts.allSatisfy { $0.count <= 150 })
                    count += 1
                }
            }
        }
        precondition(VersePagination.sections("one two three", maxWords: 2, fits: { _ in true }) == ["one two", "three"])
        precondition(VersePagination.sections("one", fits: { _ in false }) == ["one"])
        print("Passed: all \(count) verses retain every word in order and fit section limits.")
    }
}
