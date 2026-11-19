# Code Rustlers website

A standalone static website. No installation, build step, backend, analytics, or cookies. App source code and server secrets are not part of this site.

## Preview

From this folder, run `python3 -m http.server 8000`, then visit http://localhost:8000. Or open index.html directly in your browser.

## Structure

- `index.html`: studio landing page.
- `styles.css`: responsive shared design.
- `site.js`: current copyright year.
- `apps/stillword/index.html`: app resource hub and FAQs.
- `assets/`: the studio mark and copied app artwork.

Stillword is the working app name; update it before launch if needed. Legal documents are deliberately not published yet. Add approved terms and privacy documents under `apps/stillword/terms/` and `apps/stillword/privacy/`, then replace the hub's status cards with links. Add a verified support contact. Do not point App Store legal URLs to unpublished documents.

Upload only this folder to any static host (for example GitHub Pages or Cloudflare Pages). Set this directory as the publish directory; no build command is required. Google Fonts is optional; system and Georgia fallbacks work without it. No site has been deployed automatically.
