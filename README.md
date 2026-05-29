# alinbobolea.github.io

Personal website for **Nick Bobolea**, built with **Hugo** and the **PaperMod** theme.

Production site: **https://alinbobolea.github.io/**

---

## Site Structure

The homepage is a consolidated split-identity layout combining what was previously three separate pages (Home, About, Contact) into one. Navigation has two items:

| Section | Path | Description |
|---|---|---|
| **Homepage** | `/` | Identity (name, bio, contact) + selected projects + recent writing |
| **Blog** | `/blog/` | Technical articles, essays, notes |
| **Projects** | `/projects/` | Project index |

There are no standalone About or Contact pages — those are sections of the homepage. Project reference documentation is served directly from `static/docs/<project>/` (currently `/docs/htcie/` and `/docs/pygotm/`); there is no Hugo-rendered `/docs/` landing page.

---

## Tech Stack

- **Hugo** static site generator (v0.160.0, Extended)
- **PaperMod** theme (git submodule at `themes/PaperMod`)
- **TOML configuration** in `hugo.toml`
- **GitHub Pages** hosting
- **GitHub Actions** deployment (`.github/workflows/hugo.yml`)

---

## Repository Layout

```
hugo.toml                  — main site configuration
content/
  _index.md                — homepage content + front matter (projects, bio, contact links)
  blog/                    — blog posts
  projects/                — projects index
  docs/                    — docs index
layouts/
  index.html               — custom split-identity homepage layout (overrides PaperMod default)
assets/
  css/extended/
    split-home.css         — homepage split layout styles
  icons/                   — custom SVG icon set
static/
  docs/htcie/              — pre-built Sphinx docs for htcie (served as static files)
themes/PaperMod/           — PaperMod theme (git submodule)
archetypes/                — content templates for new blog posts and docs
.github/workflows/hugo.yml — GitHub Pages CI/CD pipeline
```

---

## Homepage Content

Homepage content lives entirely in `content/_index.md` as structured front matter:

```yaml
headline:       # h1 headline (supports markdown for emphasis)
bio:            # sidebar bio paragraph
contactLinks:   # list of {label, url, icon} contact entries
projects:       # list of project cards {name, status, description, tags, url}
```

The body of `_index.md` (below the front matter) renders as the intro body paragraph.

To add or update a project on the homepage, edit the `projects:` list in `content/_index.md`.

---

## Configuration

Main config: `hugo.toml`

Key settings:
- `baseURL` — `https://alinbobolea.github.io/` — do not change casually
- `params.defaultTheme = "auto"` — respects system light/dark preference; user can toggle
- `params.socialIcons` — GitHub and LinkedIn
- `menu.main` — Blog (10), Projects (20), Docs (30)

---

## Local Development

```bash
# Start dev server (shows draft posts too)
hugo server -D

# Production build
hugo --minify
```

Open: http://localhost:1313/

Hugo Extended is required (used for asset pipeline). The GitHub Actions workflow uses Hugo v0.160.0 Extended.

---

## Custom Layout Notes

The homepage uses a custom `layouts/index.html` that completely overrides PaperMod's default home template. It renders a split layout:

- **Left column (fixed):** name, title, bio, contact links — stays in view as content scrolls
- **Right column (scrolls):** `// intro`, `// selected work` (project cards), `// writing` (recent blog posts)

Styling lives in `assets/css/extended/split-home.css`. This file is automatically included by PaperMod's asset pipeline. It uses PaperMod's existing CSS variables (`--primary`, `--secondary`, `--border`, `--entry`) and adds `.dark` body-class overrides for status badge colors.

On mobile (< 768px) the sidebar stacks above the content column.

---

## Content Authoring

### Add a blog post
```bash
hugo new blog/YYYY-MM-DD-my-post.md
```
Match existing front matter: `title`, `date`, `tags`, `categories`, `draft`, `description`.

### Add a project to the homepage
Edit `projects:` in `content/_index.md`. Fields:
- `name` — display name
- `status` — `complete` or `dev`
- `description` — one-paragraph description
- `tags` — list of tech/keyword tags
- `url` — internal link (leave empty string if no docs yet)

### Add or refresh project documentation
Project docs are pre-built Sphinx HTML trees served as static files (no Hugo content pipeline). To refresh them, run `scripts/sync-docs.sh` — it rsyncs each project's `docs/build/html` into `static/docs/<project>/`, excluding sphinx artifacts (`.doctrees`, `.buildinfo`, `.cache`) and any `superpowers` planning material.

---

## Deployment

Deployed automatically to GitHub Pages on push to `main` via `.github/workflows/hugo.yml`.

The workflow:
1. Checks out repo with recursive submodules (for PaperMod)
2. Configures GitHub Pages
3. Sets up Hugo Extended v0.160.0
4. Builds with `hugo --minify`
5. Uploads artifact and deploys via `actions/deploy-pages`

Do not manually edit anything in `public/` — it is generated output.

---

## Maintainer Checklist

Before making structural changes:
- Read `hugo.toml` and `content/_index.md` first
- Preserve the `baseURL` — wrong value breaks all assets
- Do not edit generated output in `public/`
- Update this README if the site structure or workflow changes
