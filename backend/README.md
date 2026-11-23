# Verse analysis backend

## Railway hosted demo

Create a separate backend service connected to this repository. Keep Root Directory
at `/` because the server requires `BibleScroll/kjv.json` and `BibleScroll/web.json`.
Set service variable `RAILWAY_DOCKERFILE_PATH=backend/Dockerfile`. Leave custom
build/start commands empty. Add `APP_ENV=development`, `HOST=0.0.0.0`,
`GEMINI_API_KEY`, `GEMINI_MODEL`, and `DEMO_API_TOKEN` from your private local
configuration using Railway Variables. Railway supplies PORT. Never commit `.env`.
Use `/health` as the healthcheck path, deploy, then Generate Domain. Check `/health`
and set the debug app's AI_BACKEND_URL to the generated HTTPS domain, with the same
AI_BACKEND_DEMO_TOKEN. Rebuild the debug app to apply those settings.

This is a hosted demo, not a production launch: the shared token is not user
authentication, limits are process-local, and the server refuses APP_ENV=production.
Do not change that guard until production authentication and entitlement verification
are implemented. The Docker image copies only the server and Bible files, not secrets.

Local development server using Python 3, with no package dependencies. AI responses are freshly generated, never cached or written to disk. The app sends a verse ID and translation; the server loads the passage and context from the bundled Bible files. Notes and bookmarks stay on the phone.

## Run locally

Local `.env` and Xcode configuration have been created from the existing local Gemini configuration. Secrets remain gitignored. Start from the project root:

```sh
python3 backend/server.py
```

For another developer, copy `.env.example` to `.env`, supply the Gemini key and a random demo token, and put that same demo token in `Config/Backend.local.xcconfig`:

```xcconfig
AI_BACKEND_URL = http:/$()/localhost:8787
AI_BACKEND_DEMO_TOKEN = your_random_demo_token
```

Simulator uses localhost. For a physical iPhone, connect Mac and iPhone to the same Wi-Fi. Set `HOST=0.0.0.0` in `.env`, change the Xcode URL to `http:/$()/YOUR-MAC-NAME.local:8787`, allow the Mac firewall connection and the iPhone local-network permission, then rebuild. Only do this on a trusted local network. Stop the server when finished.

`GET /health` reports availability. `POST /v1/analysis` requires the demo bearer token and JSON such as `{"verseID":"JOH.3.16","translation":"KJV"}`. Failed Gemini requests return a generic 503; the app displays its existing unavailable message. Limits: ten requests per minute across the local demo and three concurrent generations. No automatic retry or duplicate billing from retries.

## Debug paywall bypass

In Xcode: Product → Scheme → Edit Scheme → Run → Arguments → Arguments Passed On Launch. Add these arguments:

```
-dev-skip-paywall
-onboarding.reconnect.completed YES
```

The first grants app access only in DEBUG builds, without modifying RevenueCat entitlement state. The second skips onboarding. Remove both to test onboarding and purchases normally. Neither grants backend subscription access or creates a purchase. Release builds ignore the bypass.

## Before deploying

This server intentionally refuses non-development mode. The shared demo token is bundled in debug builds and is not production authentication. Add authenticated user sessions, verify that user's RevenueCat entitlement server-side, enforce per-user quotas, and deploy behind HTTPS with request timeouts/body limits. Store server secrets in the host's secret manager. Then replace debug-token authentication in the iOS client with short-lived user credentials and set `AI_BACKEND_URL` in `Config/Backend.release.local.xcconfig`. Release builds have no Gemini key or demo token. No cloud sync is required for reading progress.
