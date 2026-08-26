# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Changelog policy

Before making a change here — especially one that touches architecture or an established
convention — check `CHANGELOG.md` for prior decisions on the area you're touching. Entries are
chronological; if two entries disagree about the same thing, the most recent entry is
authoritative, not the earlier one.

## Local development

- Port: `4028`
- URL: `https://rio-website-template.localhost.rio-ecosystem.nl`
## What this repo is

`rio-website-template` is a **scaffold**, not a live website: the starting point that new plain-PHP
Rio Ecosystem websites are cloned from. It is not itself deployed today — no `development`/
`production` Plesk vhost currently exists for it (unlike `rio-web-app-template`, which plays a
similar template role but also has its own live demo vhost). `deploy/post-deploy.sh` exists ahead
of any such vhost, for consistency with the rest of the ecosystem's submodule-deploy fix (see
"Deploy" below) — it is currently unusable and untested. It ships the folder layout,
vendored front-end plugins, an `.htaccess` with cache headers and versioned-asset rewriting, and
the git submodule wiring for shared Rio site dependencies — but the actual entry-point files are
intentionally empty:

- `index.php`, `inc/footer.php`, `sub/404.php` — 0 bytes, placeholders to be filled in per project
- `css/`, `js/` — empty except `.gitkeep`
- `assets/img/{favicon,backgrounds,logo,icons}/`, `assets/font/` — empty except `.gitkeep`
- `robots.txt`, `sitemap.xml` — empty, fill in per project
- `.well-known/` — empty, for domain verification files

When working in this repo directly, treat it as scaffold maintenance (folder layout, `.htaccess`
rules, submodule pins, plugin versions) rather than building out a real site — filling in the
empty entry points is what happens in a *cloned* project, not here. There is no composer.json,
package.json, build step, linter, or test suite in this repo (only a stray vendored
`plugins/jQuery-UI/v1.13.2/package.json`, which is not this project's).

## Running it locally

No build step. Point Apache (or `php -S`) at the repo root; `.htaccess` needs `mod_headers` and
`mod_rewrite`. E.g.:

```bash
php -S 0.0.0.0:4028
```

Reachable at `https://rio-website-template.localhost.rio-ecosystem.nl` via the central Caddy
reverse proxy (see "Local development" above). PHP's built-in server ignores `.htaccess`, so
cache headers / the versioned-asset rewrite / `ErrorDocument 404` won't apply under it — use real
Apache if you need to verify those.

## Deploy

Not itself deployed today — see "What this repo is" above. `deploy/post-deploy.sh` is written
ahead of any future `development`/`production` Plesk vhost, following the same
submodule-repopulation pattern used across every `rio-*-server` repo (Plesk's git "pull" deploy is
a file-copy-style deploy that leaves every `submodules/<name>/` directory empty). Do not run it
until such a vhost actually exists; see the script's own header comment.

## Submodule dependencies (`submodules/`)

Pinned via `.gitmodules` to the `production` branch of each sibling repo, all under
`github.com/Soliver098/`. `git submodule update --init --recursive` after cloning.

- **`rio-website`** — intended shared base site class (site URL helpers, asset cache-busting,
  reCAPTCHA validation) that `index.php`/`inc/footer.php` are meant to build on. **As currently
  pinned it is essentially an empty repo** — one commit, `README.md`/`CHANGELOG.md`/`LICENCE.txt`
  all 0 bytes, no PHP source at all. Don't assume any `RioWebsite` API exists yet; check the
  submodule's actual content before writing code against it.
- **`rio-style`** (`submodules/rio-style/dist/rio-style.css` / `.min.css`) — CSS utility framework:
  percentage/vh sizing classes (`.width_X`, `.height_X`), a custom grid system (`.grid_X` +
  `.grid_span_X`), flex/float helpers, container-query classes (`.container_X_only` etc.), plus
  `ipad_`/`mobile_` breakpoint variants of most of the above. This is what `css/` in a cloned
  project is expected to be built on top of.
- **`rio-monitor-sdk`** (`RioMonitorSDK.php`) — logs Error/Warning/Success events to one or more
  `rio-monitor-server` instances over HTTP. Constructor takes a `string $source` label; config is
  loaded separately via `RioConfigurationLibTrait`. Per its own README, the delivery path is
  currently broken (`APIIsLoadedConfig()`/`APIGetConfig()` aren't wired to the loaded config), so
  events won't actually deliver as committed — treat documented signatures as the intended
  contract, not a working guarantee.
- **`rio-translation-sdk`** (`RioTranslationSDK.php`) — intended client for fetching/managing
  translated literals from `rio-translation-server`. Currently a stub: wires up three dependency
  traits but exposes no translation methods, and its `require_once` paths don't match the actual
  vendored filenames (points at `RioConfigurationLib.php`/`RioSecurityLib.php`, which don't exist —
  actual files are `RioConfiguration.php`/`RioAuthorizationAPI.php`). Not usable as-is.

Given the state of `rio-website` and `rio-translation-sdk`, don't assume anything imported from
`submodules/` compiles/works end-to-end — verify against the checked-out submodule source, not the
sibling repo's README, since the README may describe the intended API rather than what's actually
committed at the pinned commit.

## `.htaccess` behavior worth knowing

- `ErrorDocument 404 /sub/404.php` — all 404s route here.
- `RewriteRule ^(js|css)/(.+)\.(.+)\.(js|css)$ $1/$2.$4 [L]` — strips a version/hash segment from
  asset filenames, e.g. a requested `js/main.<mtime>.js` is served from `js/main.js`. This is the
  "versioned-asset rewriting" the README refers to; cache-busting is done by varying the filename
  the browser requests while quietly serving the unversioned file underneath.
- Long-lived `Cache-Control`/`Expires` headers per MIME type (images/fonts: up to a year; CSS/JS:
  1 week–1 month; HTML: 1 day; JSON/XML: no caching).

## `plugins/` (vendored, version-pinned front-end libraries)

`AOS/v2.3.1` (scroll animations), `Fontawesome/v6.2.0`, `jQuery/v3.6.0`, `jQuery-UI/v1.13.2`,
`jQuery-UI-touch-punch` (touch support for jQuery UI drag/sort). These are committed vendor copies,
not package-manager-installed — bump the versioned subfolder name if upgrading, don't edit in
place.

## Releases

This repo follows the Rio Ecosystem release convention (see
`rio-ecosystem-architecture/docs/versioning.md` and
`rio-ecosystem-architecture/scripts/release.sh`). For Claude Code, hard rules apply here:

- Releases run exclusively through
  `rio-ecosystem-architecture/scripts/release.sh <repo> <major|minor|patch>`. Never run `git tag`
  by hand as a substitute for that script. Never run `gh release create` by hand as a substitute
  for that script.
- GitHub actions for releases go through the GitHub CLI (`gh`); a GitHub Release's tag must always
  equal the semver version (`vX.Y.Z`).
- Release notes come from `CHANGELOG.md`, never from a separate `RELEASE_NOTES` file.
- A version `< 1.0.0` is not a reason to mark a GitHub Release as a `prerelease`.
- An already-pushed tag is never deleted automatically, even if only creating the GitHub Release
  fails — recover with
  `rio-ecosystem-architecture/scripts/publish-github-release.sh <repo> vX.Y.Z`.
- Read-only inspection (`gh release list`, `gh release view`, `git tag -l`, `git describe --tags`)
  is always fine to use freely.
