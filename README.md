# Bible Scroll

Offline SwiftUI iPhone reader, iOS 17+. Open `BibleScroll.xcodeproj`, choose your iPhone or simulator, and press Command-R. Existing signing settings are retained.

## Included

Visual styling is shared in `AppStyle.swift`: adaptive parchment backgrounds, cream card gradients, dark ink, bronze controls, and green completion states. It follows the scroll logo and Continue Reading card without changing reading/navigation behavior.

- Home, Discover, and The Bible tabs; Home opens by default.
- Daily Reading includes local reading plans, assigned chapter links, manual reading completion, and a Browse Plans page. Home shows Today’s Reading with the selected plan, next assignment, and progress. Plans include John in 21 readings, Genesis in 25, Psalms 1–30 in 30, the New Testament in 90, and the full Bible in 365. Switching plans preserves per-plan progress; marking an assignment done also marks its chapters done in shared Bible progress. Assignments advance when explicitly marked done, not automatically by calendar date. Home now includes an illustrated devotional card linked to a detail screen, a swipe-through reading experience, and a 62-entry December/January library. Devotional completion and bookmarks are local and separate from chapter completion; reading position is stored per devotional and translation. Every reading is available in full and can be marked complete regardless of its scheduled date. Completed entries show a green tick and a Read again action. Outside the date range, Home shows the next scheduled or latest available reading, with its actual date. See `content/devotionals/README.md`.
- Home includes a local-time greeting, Verse of the Day, book/chapter/verse lookup, Continue Reading, bookmarks, reading settings, and a progress sheet. Verse actions share the reader's local notes and likes.
- Verse of the Day rotates deterministically through every verse in the active Bible library (31,102 for KJV) using the local Gregorian date. It stays constant during the day, updates while Home is visible, and works offline. A non-sequential coprime step covers every verse before repeating, rather than cycling through the Discover collection.
- Opening streaks record real local-calendar dates from this update onward, not historical estimates. Chapter totals and completed-book counts are calculated from the active Bible library and shared completion store. Home navigation can open an exact reference in The Bible without treating the jump as a chapter-completion swipe.
- Discover contains exactly 50 local cards in discover.json: 30 Scripture studies, 10 original reflections, and 10 Scripture-backed Bible facts. A persisted order mixes three Scripture studies, one reflection, and one fact per group, with entries shuffled within their types. One card appears per vertical swipe; top filters and bottom action controls are omitted.
- Discover reuses the verse-analysis sheet. Related-passage pills open analysis for the selected passage. Study cards contain complete original explanations, passage context, and applications. Reflections are original writing rather than quotations attributed to historical authors. Fact cards include supporting Scripture references and a source-reading sheet. The feed is finite; it does not generate new studies or personalize recommendations.
- Both reading tabs share one in-memory Bible library and the same bookmark/interaction stores.
- Full KJV: 66 books, 1,189 chapters, 31,102 verses bundled in kjv.json.
- Native vertical page controller across chapter and book boundaries. Swipe destinations are restricted to immediate neighbors; current and neighboring verse controllers are cached rather than laying out the entire Bible in a scroll list.
- Searchable book picker and chapter grid.
- Chapter completion circles, whole-book read/unread toggle, and completion counts in the book list. Progress persists locally using canonical book IDs plus chapter numbers, shared across future translations. Future text importers must map books to the same canonical IDs. A completed forward swipe from a chapter's last verse into the next chapter also marks the chapter done, with a brief animated green-check banner and success haptic. Opening a chapter, jumping from bookmarks, restoring a position, or swiping backward does not mark it done. Reduced Motion uses a fade.
- Persistent verse reference and adjustable text size; system light/dark appearance.
- Long verses split into sections of up to 45 words, reduced to fit the available text area. Swipe left for the next section, right for the previous section, or use the arrow buttons. Vertical swipes navigate verses.
- Save/unsave beneath each verse; toolbar bookmark opens saved verses, newest first.
- Saved verses persist locally. Tap one to return to the passage, or swipe left to remove it.

Likes and auto-saved personal notes are local and keyed by translation ID plus canonical verse reference. The bottom-right heart, pencil, and share controls provide these actions; sharing includes the full verse text, reference, and version. Bookmarks remain a separate feature. Verse analysis uses the curated studies when available; other passages show reading prompts and surrounding Scripture. There is no fabricated original-language analysis. Additional translations and on-demand study generation are future milestones.

## Text provenance

Downloaded from https://ebible.org/Scriptures/eng-kjv2006_vpl.zip on 2026-11-16.
Standardized 1769 KJV text supplied by eBible.org and the CrossWire Bible Society. Original source notice is retained in BibleScroll/KJV-source.html.
See https://ebible.org/eng-kjv2006/copr.htm for terms, including UK publication restrictions. UK distribution permissions require review before release.

Regenerate with `python3 scripts/import_kjv.py /path/to/eng-kjv2006_vpl.zip`.
The importer checks book, chapter, and verse totals and sequential numbering. It removes paragraph markers and square brackets used for supplied-word formatting, preserving their words.

## Device checks

Verify Genesis → Exodus and Malachi → Matthew boundaries, jump to Psalms 119 and Revelation 22, and reopen after reading. Try large text and Esther 8:9, switch Home → The Bible, and read in airplane mode. Compilation alone does not verify gestures or scroll restoration on a physical device.

Save two verses, reopen the app, open the toolbar bookmark, and tap a saved verse. Verify the reader jumps to it and its button says Saved. Swipe left in the saved list to remove a verse and verify the reader button updates.

Persistence checks: compile `BibleScroll/SavedVersesStore.swift` and `Tests/SavedVersesStoreTests.swift` together with `swiftc`, then run the resulting executable. The checks use a temporary preferences domain and remove it afterward.

## Subscription setup

The entire app is gated by an active RevenueCat entitlement. Configure the public SDK key, entitlement, and offerings in `Config/RevenueCat.local.xcconfig`, then rebuild. See [RevenueCat setup](docs/REVENUECAT-SETUP.md) for dashboard and sandbox testing instructions. Custom SwiftUI paywalls load real prices and trial eligibility; dashboard paywall designs are not rendered. No development bypass is available; only the active entitlement grants access.
