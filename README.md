# Rio-Website-Template

Rio-Website-Template is the starting scaffold for a new Rio Ecosystem website. It provides the
standard folder layout, vendored front-end plugins, an `.htaccess` with cache headers and
versioned-asset rewriting, and the git submodule wiring for the shared Rio site dependencies. Use
it as the basis for a new project rather than modifying it in place.

## Installation

```bash
git clone <repo-url> new-site-name
cd new-site-name
git submodule update --init --recursive
```

There are no placeholder tokens to find-and-replace in this scaffold today — `index.php`,
`inc/footer.php`, `sub/404.php`, `css/`, `js/`, `robots.txt`, and `sitemap.xml` are all present
but empty, so starting a new project means cloning the template and filling in these entry
points for the new site. Point your Apache vhost's document root at the cloned folder; the
included `.htaccess` handles asset cache headers and the 404 document out of the box.

## Dependencies

- [`RioWebsite`](submodules/RioWebsite) — shared base site class (site URL helpers, asset
  cache-busting, reCAPTCHA validation)
- [`RioStyle`](submodules/RioStyle) — CSS utility framework used for layout and styling
- [`RioMonitorAPI`](submodules/RioMonitorAPI) — monitoring/observability integration
- [`RioTranslationAPI`](submodules/RioTranslationAPI) — translation lookups

## Development

The folder structure is:

- `index.php` — main entry point (empty placeholder, to be filled in per project)
- `inc/` — shared PHP includes, e.g. `footer.php` (empty placeholder)
- `sub/` — secondary pages, e.g. `404.php`, wired up as the custom error document in `.htaccess`
  (empty placeholder)
- `css/`, `js/` — project-specific stylesheets and scripts (empty, kept in git via `.gitkeep`)
- `assets/img/` — static image folders: `favicon/`, `backgrounds/`, `logo/`, `icons/` (empty,
  kept in git via `.gitkeep`)
- `assets/font/` — project fonts (empty, kept in git via `.gitkeep`)
- `plugins/` — vendored third-party front-end libraries, pinned by version:
  - `AOS/v2.3.1` — scroll animations
  - `Fontawesome/v6.2.0` — icon font
  - `jQuery/v3.6.0`
  - `jQuery-UI/v1.13.2`
  - `jQuery-UI-touch-punch` — touch support for jQuery UI drag/sort interactions
- `submodules/` — the Rio dependencies listed above
- `.htaccess` — sets far-future cache headers per asset type, rewrites versioned static asset
  filenames (`main.<mtime>.css` → `main.css`), and routes 404s to `sub/404.php`
- `robots.txt`, `sitemap.xml` — present but empty; fill in per project
- `.well-known/` — present, empty; for domain verification files as needed per project
