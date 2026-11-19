import Foundation

private final class MockGemini: URLProtocol {
    static var status = 200
    static var payload = Data()
    static var calls = 0
    static var networkFailure = false
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        Self.calls += 1
        precondition(request.url?.query == nil, "The API key must not appear in URLs")
        precondition(request.cachePolicy == .reloadIgnoringLocalAndRemoteCacheData)
        precondition(request.value(forHTTPHeaderField: "Cache-Control") == "no-store")
        precondition(request.value(forHTTPHeaderField: "x-goog-api-key") == "test-key")
        if Self.networkFailure {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: Self.status,
                                                            httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.payload)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@main struct GeminiAnalysisTests {
    static func main() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockGemini.self]
        let session = URLSession(configuration: configuration)
        let verse = Verse(bookID: "JOH", bookName: "John", chapter: 1, number: 1, text: "In the beginning was the Word.")
        let fields = ["explanation": "A simple explanation", "deeperStudy": "A deeper study", "historicalContext": "Historical context",
                      "originalLanguage": "Original language", "application": "An application"]
        var result: [String: Any] = fields
        result["relatedVerseIDs"] = ["GEN.1.1"]
        func envelope(_ value: [String: Any], finish: String = "STOP") throws -> Data {
            let text = String(data: try JSONSerialization.data(withJSONObject: value), encoding: .utf8)!
            return try JSONSerialization.data(withJSONObject: ["candidates": [["finishReason": finish, "content": ["parts": [["text": text]]]]]])
        }
        MockGemini.payload = try envelope(result)
        let service = GeminiAnalysisService(session: session)
        let first = try await service.generate(verse: verse, translation: "KJV", context: [verse], key: "test-key", model: "gemini-test")
        precondition(first.explanation == "A simple explanation")
        _ = try await service.generate(verse: verse, translation: "KJV", context: [verse], key: "test-key", model: "gemini-test")
        precondition(MockGemini.calls == 2, "Repeated requests must always reach Gemini")
        _ = try await service.generate(verse: verse, translation: "WEB", context: [verse], key: "test-key", model: "gemini-test")
        precondition(MockGemini.calls == 3, "Switching translation must make a new request")
        MockGemini.status = 401
        do {
            _ = try await service.generate(verse: verse, translation: "KJV", context: [verse], key: "test-key", model: "gemini-test")
            fatalError("A prior success must not hide an expired key")
        } catch { }
        precondition(MockGemini.calls == 4)
        MockGemini.status = 200
        func expectFailure(key: String = "test-key", model: String = "gemini-test") async throws {
            let fresh = GeminiAnalysisService(session: session)
            do {
                _ = try await fresh.generate(verse: verse, translation: "KJV", context: [verse], key: key, model: model)
                fatalError("Expected request to fail")
            } catch { }
        }
        let before = MockGemini.calls
        try await expectFailure(key: "")
        try await expectFailure(model: "invalid/model")
        precondition(MockGemini.calls == before)
        for status in [400, 401, 403, 429, 500, 503] {
            MockGemini.status = status
            try await expectFailure()
        }
        MockGemini.status = 200
        MockGemini.payload = Data("invalid JSON".utf8)
        try await expectFailure()
        MockGemini.payload = try envelope(result, finish: "MAX_TOKENS")
        try await expectFailure()
        var empty = result; empty["explanation"] = "  "
        MockGemini.payload = try envelope(empty)
        try await expectFailure()
        MockGemini.payload = Data("{\"candidates\":[]}".utf8)
        try await expectFailure()
        MockGemini.networkFailure = true
        try await expectFailure()
        print("Passed fresh-request behavior, disabled HTTP caching, expired key after success, decoding, missing key, invalid model, HTTP failures, malformed output, and offline failure.")
    }
}
