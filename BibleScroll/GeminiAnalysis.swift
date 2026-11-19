import Foundation

struct GeminiAnalysis: Decodable {
    let explanation: String
    let deeperStudy: String
    let historicalContext: String
    let originalLanguage: String
    let application: String
    let relatedVerseIDs: [String]

    var isValid: Bool {
        [explanation, deeperStudy, historicalContext, originalLanguage, application]
            .allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}

actor GeminiAnalysisService {
    static let shared = GeminiAnalysisService()
    enum Failure: Error { case unavailable }
    private let session: URLSession

    init(session: URLSession? = nil) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = session ?? URLSession(configuration: configuration)
    }

    func generate(verse: Verse, translation: String, context: [Verse]) async throws -> GeminiAnalysis {
        let rawURL = Bundle.main.object(forInfoDictionaryKey: "AIBackendURL") as? String ?? ""
        guard let baseURL = URL(string: rawURL), let host = baseURL.host else { throw Failure.unavailable }
        #if DEBUG
        guard ["http", "https"].contains(baseURL.scheme ?? "") else { throw Failure.unavailable }
        #else
        guard baseURL.scheme == "https", host != "localhost", host != "127.0.0.1" else { throw Failure.unavailable }
        #endif
        try Task.checkCancellation()
        var request = URLRequest(url: baseURL.appendingPathComponent("v1/analysis"), timeoutInterval: 45)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        #if DEBUG
        let token = Bundle.main.object(forInfoDictionaryKey: "AIBackendDemoToken") as? String ?? ""
        guard !token.isEmpty, !token.contains("$(") else { throw Failure.unavailable }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        #endif
        request.httpBody = try JSONSerialization.data(withJSONObject: ["verseID": verse.id, "translation": translation])
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw Failure.unavailable }
        let result = try JSONDecoder().decode(GeminiAnalysis.self, from: data)
        guard result.isValid else { throw Failure.unavailable }
        return result
    }
}
