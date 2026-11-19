# Gemini verse analysis — local demo

1. In Xcode's project navigator, open Gemini.local.xcconfig (workspace path: Config/Gemini.local.xcconfig).
2. Set GEMINI_API_KEY = your_key on its existing line. Do not add quotes.
3. Run the Debug build on your iPhone with Cmd+R.
4. Open any verse, then Verse analysis. The selected passage and nearby verses are sent to Google's Gemini API; personal notes are not sent.

The default model is gemini-3.5-flash-lite. To use another supported model available to your API project, add GEMINI_MODEL = model-name in the same local file and rebuild.

The key file is ignored by git. Debug.xcconfig includes it optionally, so a checkout without a key still builds. Only Debug builds receive the key in their generated Info.plist. Direct client API access is for local recording/testing, not production; a production release needs a server-side credential or an appropriate Firebase AI Logic setup. Keys in an installed demo app are extractable.

Missing/invalid/expired keys, permissions, quota, offline, timeout, blocked content, and malformed responses all show “AI features aren’t available right now.” Retry is user-initiated; there are no automatic retry loops. No generated responses are cached or persisted. Every opening or retry makes a fresh request. The URL session is ephemeral with its HTTP cache disabled, and requests use a no-store cache directive. No prepared Discover content is presented as a generated response.

Reference: https://ai.google.dev/api/generate-content
Model: https://aistudio.google.com/docs/models/gemini-3.5-flash-lite

Verification without a live API key:
`swiftc BibleScroll/Verse.swift BibleScroll/GeminiAnalysis.swift Tests/GeminiAnalysisTests.swift -o /private/tmp/GeminiAnalysisTests`
Then run `/private/tmp/GeminiAnalysisTests`.
