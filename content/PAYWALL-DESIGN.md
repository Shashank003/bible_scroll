# First offer screen

Native SwiftUI recreation of the supplied RevenueCat design. Canvas and type use AppStyle. Watercolor header, four feature rows, annual/weekly choice, renewal wording, legal controls. Annual is selected by default.

Both screens are backed by the RevenueCat SDK. Prices and billing periods come from configured packages; no dollar amounts are hardcoded. A free-trial badge, timeline, and CTA are shown only when RevenueCat reports eligibility for the actual free introductory offer. An unavailable offering has no fake price or purchasable fallback.

First CTA purchases the selected package. The first close control opens the second offering; closing the second returns to the first. Purchases and restores unlock only after the configured entitlement is active. Terms and Privacy use configured URLs; missing URLs show pending content and must be supplied before release.

The screen scrolls when the content exceeds the safe area, including accessibility sizes. Price cards have at least 66pt height; Continue is 56pt; footer links have 44pt hit areas.

Header generated as original artwork with the built-in image-generation tool. Prompt: Wide watercolor sunrise over sand-colored rolling hills, small wooden cross on distant hill right of center; cream parchment, pale apricot and honey washes; generous space; no text, logos, frames or UI. Original artifact: /Users/admin/.codex/generated_images/01a1b1d1-1a8a-7161-bc30-a907056f9a21/exec-91c2f743-a065-4115-a6a4-5113dfc65b67.png

## Second offer screen

Warm annual-plan follow-up with sunrise header, gift icon badge, bordered annual price card, four compact benefit rows, primary CTA, renewal terms, and legal links. The X returns to the first screen. It uses the annual package in the configured second offering; no fake discount or exclusive scarcity claim is made. The whole screen scrolls when needed and uses scalable typography and native safe areas. The second package is not offered if an eligible free trial would apply, because this screen is intentionally a no-trial offer.

## Reader-stories layout

The first paywall uses a taller sunset header, serif headline, compact 2-column benefit cards, subscription options, and a reader-story section. The purchase/renewal/legal footer stays visible at standard text sizes; at accessibility sizes it joins the scroll content to keep every control reachable. Read more stories opens a dedicated sunset-and-parchment sheet.

All three stories are original illustrative copy, visibly marked as not actual user reviews on the preview and full screen. No ratings, identities, headshots, donation-funding claims, or fabricated user counts are included. Replace illustrative copy with genuine, permissioned reviews before presenting it as real social proof. RevenueCat purchase logic is unchanged.

## Sizing correction

Both paywalls now have an explicit viewport width capped at 500pt, and the sunset artwork is drawn as an overlay inside a fixed-size rectangle, so the wide source image cannot expand layout width. The first screen uses a shorter hero, compact benefit rows, and an expandable stories link. The checkout footer remains safe-area-aware; accessibility text sizes put the footer in the scroll content. A simulator screenshot verified real RevenueCat prices and the trial card fit horizontally with no clipping.

## Inline reader stories

All three story cards appear vertically inside the paywall’s main ScrollView; the separate stories sheet and decorative per-story themes were removed. Fictional US-style display names accompany the generated sample quotes, with a visible sample label. Genuine feedback and authorized attribution should replace these before they are represented as actual reviews.

The annual option has a prominent recommendation band. It can show Most popular / Most subscribers only when the authenticated first offering’s metadata includes subscription_counts.annual and subscription_counts.weekly and annual has a strictly larger positive count. Without those counts, the band says Recommended for your daily rhythm. Counts must be maintained from actual subscription data; the SDK does not supply live popularity metrics.

These changes were written without running builds or tests, as requested.

## Current review publication and annual badge

The owner confirms annual is the most popular plan; its band always reads MOST POPULAR. Generated quote copy and display names are preserved in reader-reviews.json as unpublished drafts (isPublished: false). The customer-facing view has no sample labels. Once the owner supplies actual feedback and attribution, replace the draft text and publish the corresponding records; published cards appear inline vertically without per-card headings. No builds or tests were run for this edit.

## Current review content

Four visible inline cards use explicit lorem ipsum placeholder text and display names Kevin, Mark, Sydney, and Jason, as requested. The UI has no placeholder labels or decorative per-card headings. The JSON-driven layout handles multiline text, Dynamic Type, empty entries, and duplicate IDs. Replace the Latin placeholder copy with genuine feedback and approved attribution before release. All cards scroll vertically within the existing paywall. No build or tests were run for this edit.
