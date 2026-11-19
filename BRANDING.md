# App logo

Created using the built-in image generation tool from the user-supplied scroll-and-cross artwork.

- Transparent reusable logo: `BibleScroll/Assets.xcassets/AppLogo.imageset/AppLogo.png` (asset name `AppLogo`).
- iOS app icon: `BibleScroll/Assets.xcassets/AppIcon.appiconset/AppIcon.png` (1024 × 1024, opaque). Xcode uses the AppIcon asset for Debug and Release.
- The app icon uses a full-bleed beige background; iOS applies the outer corner mask.

## Transparent logo prompt

Use case: background-extraction. Edit target: the user's attached parchment scroll with brown Christian cross on a warm beige rounded-square tile. Remove ONLY the white outer background beyond the beige rounded-square tile, making that outer region truly transparent. Preserve the entire beige tile, its rounded corners, the 3D parchment scroll, cross, warm colors, lighting, shadows and proportions exactly. No redesign, no new text or elements. Center the tile and crop close to its bounds so there is no large white margin. Output a high-resolution square transparent PNG logo asset for an iPhone Bible app. Preserve pale highlights on the parchment; they are not background.

## App icon prompt

Use case: precise-object-edit. Asset: production iOS app icon. Use the attached scroll and cross logo as the edit target. Preserve the parchment scroll, brown cross, two horizontal marks, lighting, 3D style, and warm cream/beige palette. Remove the outer empty/transparent margin by extending the existing warm beige tile background to cover the entire square canvas, all the way to all four edges and corners. Output an opaque full-bleed square icon: NO white border, NO transparency, NO pre-rounded tile corners, NO outer frame, NO text. iOS will supply its own corner mask. Center the parchment scroll, make it prominent at roughly 70 percent of canvas width and 76 percent height, with comfortable symmetrical breathing room. Preserve artwork faithfully.
