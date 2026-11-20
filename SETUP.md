# Site Setup & Local Development Guide

This repo builds `trobacker.github.io` using [Quarto](https://quarto.org/). This
document explains how the repo is structured, how to preview the site locally,
and how publishing to GitHub Pages works.

## Prerequisites

- **Quarto** — already installed on this machine (`quarto --version` → 1.8.25).
  If reinstalling elsewhere: https://quarto.org/docs/get-started/
- **Git**
- Python is *not* required for this setup (no code chunks are being executed
  yet). If you later add executable Python chunks to a `.qmd` file, create a
  local virtual environment first:
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  pip install jupyter
  ```
  Quarto will auto-detect the Jupyter kernel. Add `.venv/` to `.gitignore`
  (already included).

## Repo structure

```
trobacker.github.io/
├── _quarto.yml              # site config: nav, theme, output dir
├── styles.css               # custom CSS overrides
├── index.qmd                # home page
├── cv.qmd                   # CV page (also renders Thomas_Robacker_CV.pdf)
├── talks/                   # prebuilt, self-contained slide decks
├── _talks-src/              # deck sources; build with _talks-src/build.sh
├── _site/                   # generated HTML (gitignored, not committed)
├── .github/workflows/
│   └── publish.yml          # GitHub Actions: render + deploy on push to main
└── .gitignore
```

## Previewing the site locally

From the repo root:

```bash
quarto preview
```

This renders the site and opens it in your browser with live-reload — edits
to any `.qmd` file automatically re-render and refresh the page. Stop it with
`Ctrl+C`.

To just render without a live server (e.g. to sanity-check before pushing):

```bash
quarto render
```

Output goes to `_site/` (gitignored — it is *not* committed; GitHub Actions
rebuilds it on every push).

### Using Positron

Positron can run the above commands in its integrated terminal. You can also
open `.qmd` files directly and use Positron's rendering integration if
available. There is no special Positron project config needed beyond this
repo's `_quarto.yml`.

## Publishing to GitHub Pages

Deployment is automated via `.github/workflows/publish.yml`: every push to
`main` triggers a GitHub Actions run that:

1. Checks out the repo
2. Installs Quarto
3. Runs `quarto render`
4. Uploads `_site/` as a Pages artifact and deploys it

**One-time repo setting required:** in the GitHub repo, go to
**Settings → Pages** and set **Source** to **"GitHub Actions"** (not "Deploy
from a branch"). Without this, the workflow will run but Pages won't serve
the result.

After that, the day-to-day workflow is just:

```bash
git add .
git commit -m "Update CV"
git push origin main
```

...and the live site at `https://trobacker.github.io` updates automatically
within a minute or two. Check the **Actions** tab on GitHub if a deploy
doesn't show up — it will show build errors there if `quarto render` fails.

## Adding new pages

1. Create a new `.qmd` file (e.g. `projects.qmd`).
2. Add a YAML header:
   ```yaml
   ---
   title: "Projects"
   ---
   ```
3. Add it to the `navbar` list in `_quarto.yml` if you want it in the nav.
4. Preview locally (`quarto preview`) before committing.

## Notes

- Theme (`cosmo`) and nav structure in `_quarto.yml` are easy to swap; see
  https://quarto.org/docs/output-formats/html-themes.html for other built-in
  Bootswatch themes.
