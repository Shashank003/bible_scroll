# Daily devotional library

62 original devotionals cover every date from December 1, 2026 through January 31, 2027.

- December: **Light in the Waiting** — 31 readings about hope, the birth narratives, practical love, and year-end reflection.
- January: **Faith for the Everyday** — 31 readings about prayer, sustainable practices, wisdom, relationships, rest, and service.

The app-ready content is `BibleScroll/devotionals.json`. The two monthly Markdown files are readable review copies. Edit the JSON as the source of truth and keep review copies synchronized when revising the writing.

Each entry includes a stable ID and local publication date (YYYY-MM-DD), series/day number, title, canonical Scripture references, introduction, complete reflection, practical response, short prayer, and an original-writing attribution. Scripture is not duplicated into devotional prose as a substitute for the chosen translation. The reader resolves references using the current Bible library; future translations must use the same canonical IDs.

The text was newly authored for this app, not extracted from a competitor or attributed to another writer. Biblical context is grounded in the referenced passages. Interpretation and application are editorial devotional writing, not additional Scripture. Content review remains appropriate before public release.

`DevotionalLibrary` provides sorted entries and lookup by Gregorian date in the user's time zone. It returns no entry outside the supplied date range. Reading-time estimates include both devotional writing and the selected translation's Scripture text, at 180 words per minute.

The library is connected to Home. The illustrated Home card opens a detail screen, then a native vertical swipe reader with an introduction, Scripture pages, reflection sections, a practical response, a prayer, and an explicit Finish action. Opening or swiping through a reading alone never marks completion. The archive lists all dates; every entry is readable in full and can be completed regardless of date. Reading positions are saved by stable step ID and translation. Bookmarks and completion belong to the devotional across translations, independently of Bible chapter progress.

Before December 1, Home shows the first full devotional with its scheduled date. After January 31 it shows the latest entry rather than inventing a daily reading. The current library is available offline. Original seasonal cover art and its prompts are recorded in ARTWORK.md.

`Tests/DevotionalFlowTests.swift` verifies date selection, unrestricted completion and rereading, completion idempotence, bookmarks, translation-specific resume, and complete preservation of reflection and Scripture text when constructing reading pages.

## Validation

Run `python3 scripts/validate_devotionals.py` for date coverage, unique titles, substantive text, complete fields, Scripture-reference checks, and placeholder detection.

`Tests/DevotionalLibraryTests.swift` checks date lookup, local midnight, the year boundary, missing dates, references, and reading-time estimates. Compile it with Verse.swift and Devotional.swift; provide the JSON path when running. The test executable also needs kjv.json beside it for BibleLibrary's bundle lookup.
