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

## Railway

Set the landing-page service Root Directory to `/code_rustlers_landing_page`.
Clear custom Build and Start commands, including any earlier `cd` / Python command.
Railway detects the Dockerfile and runs nginx with the assigned PORT automatically.
Commit and push these files, then redeploy. Generate a public domain under Networking
and connect coderustlers.com there. Keep the AI backend in a separate service.
Only public website files are copied into the image; internal Markdown checklists
and the rest of the iOS repository are excluded.

## Public pages

- `/`: Code Rustlers studio.
- `/apps/stillword/`: Stillword resources, support email, and Apple refund help.
- `/apps/stillword/terms/`: terms of service.
- `/apps/stillword/privacy/`: privacy policy.

Brand: Code Rustlers, sole proprietorship, India. Product: Stillword. Domain: coderustlers.com. Contact: contact@coderustlers.com. No store download buttons are included.

The documents have public-facing wording. Internal implementation and owner follow-ups are in LEGAL-REVIEW.md. Policy wording does not implement analytics consent, age restrictions, or production security. App legal URLs should be updated after this website is publicly deployed.

Upload only this folder to any static host (for example GitHub Pages or Cloudflare Pages). Set this directory as the publish directory; no build command is required. Google Fonts is optional; system and Georgia fallbacks work without it. No site has been deployed automatically.
