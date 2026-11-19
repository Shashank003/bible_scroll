# RevenueCat integration

The app uses RevenueCat's core iOS SDK (Swift Package Manager, resolved version in Package.resolved) with custom SwiftUI paywalls. RevenueCatUI templates are not used; editing the dashboard paywall design does not change this native layout. Offerings, products, localized prices, trial eligibility, purchase, restore, and entitlement status come from RevenueCat.

## Configure locally

Open `Config/RevenueCat.local.xcconfig` in Xcode's project navigator. Fill in:

```
REVENUECAT_PUBLIC_API_KEY = appl_your_public_ios_sdk_key
REVENUECAT_ENTITLEMENT_ID = your_entitlement_identifier
REVENUECAT_OFFERING_ID = your_first_offering_identifier
REVENUECAT_SECOND_OFFERING_ID = your_second_offering_identifier
REVENUECAT_SECOND_PACKAGE_ID = your_discounted_annual_package_identifier
PAYWALL_TERMS_URL = https:/$()/your-domain/terms
PAYWALL_PRIVACY_URL = https:/$()/your-domain/privacy
```

Use exactly the identifiers from the RevenueCat dashboard, not display names. Leave the first offering identifier blank to use the current/default offering. URLs use `$()` to prevent xcconfig treating `//` as a comment. This local configuration is git-ignored. It contains only RevenueCat's PUBLIC SDK key; never put private API keys or Apple P8 credentials here. Settings apply to Debug and Release. Gemini remains Debug-only.

The app Bundle ID is currently `com.coderustlers.scrollbible`; the Apple app configuration in RevenueCat must match it exactly. Product IDs come from the configured packages, so no product IDs are hardcoded in Swift.

## RevenueCat dashboard

- Primary offering: annual and weekly (or other desired subscription) packages.
- Every product that should unlock this app must be attached to the configured entitlement.
- The first annual product must have a 7-day free introductory offer configured in App Store Connect. The app shows that offer only for an eligible customer and uses its actual period.
- The second offering must contain the exact annual package configured by REVENUECAT_SECOND_PACKAGE_ID. The current project uses custom_yearly_2, which RevenueCat maps to biblescroll.premium.discounted_annual. This is intentionally not the standard $rc_annual package. It should not provide an eligible free trial. The UI does not falsely hide a trial: that package is not offered on the no-trial second screen if a free trial would apply.
- There is no fallback from an incorrect offering identifier to another product. Missing products show unavailable state, without invented prices or purchase actions.

## Behavior

The entire app requires an active configured entitlement. Onboarding completion alone does not unlock access. Purchase and restore unlock only after RevenueCat's returned CustomerInfo reports that entitlement active. Existing subscribers are checked on launch/foreground, and entitlement updates are observed via PurchasesDelegate. An interrupted purchase, cancellation, missing configuration, or restore without an active entitlement does not unlock the app.

First CTA purchases the selected package. The sole top-left X on the first screen shows the rescue offer; closing the second returns to the first. Restore is available on both screens and Settings → Subscription. Settings also links to Apple's subscription-management page.

No development bypass exists in any build. The legacy bypass preference is removed on launch and never grants access. Release builds also reject Test Store keys.

## Testing on your iPhone

1. Fill the configuration and rebuild with Cmd+R.
2. Open the paywall (or replay onboarding from Settings if you already have an active subscription).
3. Confirm actual local currency and product durations appear.
4. Check trial eligibility with an eligible Apple Sandbox tester; an ineligible tester must not see a promised trial.
5. Complete a sandbox purchase and verify the active entitlement in RevenueCat's sandbox customer record.
6. Test canceling the Apple purchase sheet, purchase errors, restore, an account with no purchases, and subscription expiry.
7. Verify both primary products and the follow-up product grant the same entitlement.
8. Verify Terms/Privacy links open real pages.

A Test Store key (`test_...`) may be used in Debug, but only an Apple `appl_...` key is accepted in Release. Apple Sandbox and RevenueCat Test Store are separate environments. Do not submit with the Test Store key.

No live purchase was tested during implementation because the project's API key and identifiers have not yet been supplied.
