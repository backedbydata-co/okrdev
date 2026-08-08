# site/ — the okrdev landing page

One file: [index.html](index.html). Self-contained by design — inline CSS, a data-URI favicon,
no scripts, no relative assets, no build step. Open it in a browser and what you see is what
production serves.

## How it deploys

Vercel project **`okrdev-site`** on the `okrdev` team, linked to this repo. There is no deploy
button and no CLI step:

- **Open a PR** → a preview deployment appears on it at its own URL.
- **Merge to `main`** → production deploys.

That is the whole pipeline. A second path to production would accumulate state this repo cannot
see, which is why [`vercel.json`](../vercel.json) — not a dashboard form — holds the settings
that decide what ships.

## What vercel.json does

| Key | Effect |
|---|---|
| `outputDirectory: "site"` | Serves this directory as the web root. Vercel's Root Directory stays at the repo root, so the config lives in git rather than in a dashboard field. |
| `framework: null`, `installCommand: ""`, `buildCommand: ""` | No framework detection, no install, no build. A static copy. The empty strings also pin the behaviour against a build command later being typed into the dashboard. |
| `cleanUrls`, `trailingSlash` | `/` serves `index.html`; no `.html` suffixes. |
| `headers` | CSP (`script-src 'none'` — the page has no JS), HSTS, `nosniff`, a referrer policy, and a `Permissions-Policy` denying camera/mic/geolocation. |

[`.vercelignore`](../.vercelignore) keeps the upload to `site/` + `vercel.json`, so `docs/`,
`skills/`, `templates/`, `tests/` and `dist/` never enter the deploy payload.

## Changing the page

Edit `index.html`, open a PR, click the preview link, merge. If you add anything with
behaviour — a form, analytics, any JavaScript — three things stop being true at once: the CSP
denies scripts, the "no Playwright" exception loses its argument, and the "no database" rows go
with it. Revisit the exception table in [`okrdev/config.md`](../okrdev/config.md) in the same PR
rather than after.

Why those exceptions exist, and the mapping mode they follow, is recorded there and in
[issue #1](https://github.com/backedbydata-co/okrdev/issues/1).
