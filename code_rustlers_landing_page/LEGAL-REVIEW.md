# Legal review — 20 November 2026

Local drafts are available at `/apps/stillword/terms/` and `/apps/stillword/privacy/`. They are original text based on this app's implementation; competitor documents were used to identify coverage areas, not copied.

## Sources reviewed

- Competitor's native-app terms: https://thejcbsnbrand.com/apps/scroll-the-bible/terms
- Competitor's native-app privacy policy: https://thejcbsnbrand.com/apps/scroll-the-bible/privacy
- Apple Standard EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
- RevenueCat privacy: https://www.revenuecat.com/privacy/
- Gemini API terms: https://ai.google.dev/gemini-api/terms

Competitor-specific integrations (Superwall, OpenAI, Supabase, Meta, AppsFlyer, online translation providers, Android billing) were not imported into our documents.

## Required owner decisions before public release

- Legal operator name, address, country/jurisdiction, verified public support/privacy email, and final product name.
- Confirm production Gemini billing tier, permitted audience (current Gemini terms restrict API clients accessed by under-18 users), regions, necessary consent, and provider retention. A policy alone does not implement age controls or consent.
- Choose production hosting, authenticated backend access, subscription verification, security controls, logging, retention, and data-transfer arrangements. Current demo backend refuses production mode.
- Confirm subscription terms and all promotional/giving claims against actual practices. No donation amount, beneficiary, nonprofit status, or tax-deductibility promise has been invented in these documents.
- Decide whether to self-host Google Fonts; current website requests them externally.
- Review with qualified counsel for target markets. Local draft status and unfinished fields should not be removed until these matters are resolved.

The iOS paywall's existing snaprise.io URLs remain unchanged; localhost cannot serve as a public App Store legal URL. Change those only after approved documents have a public address.
