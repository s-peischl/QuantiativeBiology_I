# Quantitative Biology I — Collaborator Guide

Teaching materials for **Quantitative Biology I** (bridge course).  
Live site: **https://s-peischl.github.io/QuantiativeBiology_I/**  
Repository: **https://github.com/s-peischl/QuantiativeBiology_I**

This README explains how collaborators edit slides, notebooks, and assignments with **Quarto**, then publish changes via **GitHub**.

---

## Course arc (context)

**Eco → Evo (deterministic → random) → Microbiome (ecology with randomness)**

| Weeks | Focus |
|------:|-------|
| 1 | Hook — Bajau / Andika |
| 2–4 | Ecology |
| 5–7 | Evolution (deterministic) |
| 8–10 | Evolution (random) |
| 11–13 | Microbiome |
| 14 | Project |

Canonical materials live under `weeks/week-XX/`, not under the older `modules/.../weeks/...` trees.

---

## What you need installed

1. **Git**
2. **Quarto** — https://quarto.org/docs/get-started/
3. **R** (for notebooks / executable slide chunks) — https://cran.r-project.org/
4. An editor:
   - **RStudio** (Quarto Preview built in), or
   - **VS Code / Cursor** with the Quarto extension

Check versions:

```bash
quarto --version
R --version
git --version
```

Optional: if you use RStudio’s bundled Quarto on macOS, the binary is often:

```text
/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto
```

You can alias that, or install a standalone Quarto and put it on your `PATH`.

---

## Clone and open the project

```bash
git clone https://github.com/s-peischl/QuantiativeBiology_I.git
cd QuantiativeBiology_I
```

Open the **folder** in RStudio / VS Code / Cursor (not a single file). Quarto needs the project root so `_quarto.yml`, paths like `../../pics/...`, and website rendering work.

---

## Repository map

```text
.
├── README.md                 ← this guide
├── index.qmd                 ← site home
├── _quarto.yml               ← website config (navbar, what gets rendered)
├── styles.scss               ← shared HTML styling
├── docs/
│   ├── course-outline.qmd    ← semester plan (students)
│   └── for-collaborators.qmd ← same guide on the live site
├── weeks/
│   ├── _metadata.yml         ← shared defaults (do NOT set format here)
│   └── week-01 … week-14/
│       ├── slides.qmd        ← Reveal.js lecture deck
│       ├── notebook.qmd      ← student notebook
│       ├── assignment.qmd    ← homework / exit work
│       └── data/             ← week-specific CSVs (when needed)
├── pics/                     ← images (see pics/README.md for credits)
├── templates/                ← starter files for new weeks
├── modules/                  ← high-level module notes only (not week sources)
└── .github/workflows/        ← GitHub Pages deploy
```

**Rule of thumb:** edit `weeks/week-XX/*.qmd`. Do not recreate week content under `modules/`.

---

## Editing slides (Quarto + Reveal.js)

### File to edit

```text
weeks/week-XX/slides.qmd
```

Each deck starts with YAML that **must** declare Reveal.js:

```yaml
---
title: "Week X — Title"
subtitle: "…"
author: "…"
format:
  revealjs:
    theme: simple
    slide-number: true
    embed-resources: true
    # … keep the other revealjs options from an existing week
---
```

**Critical:** do **not** add a project-level `format: html` to `_quarto.yml`, and do **not** put `format:` in `weeks/_metadata.yml`. That forces every week document into one format and breaks slide decks.

### Slide structure

- A slide is a level-2 heading: `## Slide title`
- Horizontal rule `---` can separate major sections
- Bullets, tables, math, and code chunks work as in Quarto Markdown

Examples:

```markdown
## Learning goals

- Goal 1
- Goal 2

## An equation

$$
\frac{dN}{dt} = rN - aNP
$$

## Two columns

:::: {.columns}
::: {.column width="50%"}
Left column
:::
::: {.column width="50%"}
Right column
:::
::::

## Image

![Caption](../../pics/bajau/bajau_sampela_daily.jpg){fig-alt="Alt text" width="70%"}

## Speaker notes (presenter view)

::: {.notes}
Say this out loud; students don't see it on the slide face.
:::
```

### R code on slides

```markdown
```{r}
#| fig-height: 4
#| fig-width: 7
alone <- read.csv("data/paramecium_alone.csv")
plot(alone$day, alone$paramecium, type = "b")
```
```

Paths in chunks are relative to the `.qmd` file’s folder (`weeks/week-02/`), so `data/...` means `weeks/week-02/data/...`.

### Preview slides correctly

Slides are **Reveal.js**, not a normal Markdown preview.

**RStudio:** open `slides.qmd` → **Render** / **Quarto Preview**.

**Terminal:**

```bash
quarto preview weeks/week-02/slides.qmd
# or explicitly:
quarto render weeks/week-02/slides.qmd --to revealjs
```

Then open:

```text
_site/weeks/week-02/slides.html
```

Keyboard once open: `←` `→` move · `M` menu · `Esc` overview · `F` fullscreen · `S` speaker notes (if enabled).

**Do not** rely on the editor’s plain Markdown preview — that shows a document, not a deck.

### New week from template

```bash
cp templates/slides-template.qmd weeks/week-03/slides.qmd
# also notebook + assignment templates as needed
```

Then update title, week number, navigation links at the bottom, and content.

---

## Editing notebooks and assignments

| File | Audience | Format |
|------|----------|--------|
| `weeks/week-XX/notebook.qmd` | in-class / lab | HTML |
| `weeks/week-XX/assignment.qmd` | homework | HTML |

Preview:

```bash
quarto preview weeks/week-02/notebook.qmd
quarto preview weeks/week-02/assignment.qmd
```

Keep student-facing instructions clear; put solutions in a separate file or private branch if needed (do not commit answer keys to `main` unless intended).

---

## Images and data

### Images

- Put course images in `pics/` (subfolders like `pics/bajau/`, `pics/organisms/` are fine).
- From a week file, the relative path is usually `../../pics/...`.
- Record licenses in `pics/README.md` (required for Wikimedia / CC material).
- Prefer openly licensed images; personal photos need permission.

### Data

- Week-specific CSVs go in `weeks/week-XX/data/`.
- Document sources in that folder’s `README.md` (see Week 2 Gause data).

---

## Local full-site render

From the project root:

```bash
quarto render
```

Output goes to `_site/` (gitignored). The public site is built the same way on GitHub Actions.

---

## GitHub workflow (how changes go online)

### Branching (recommended for collaborators)

```bash
git checkout main
git pull origin main
git checkout -b week-03-slides
# … edit files …
git status
git add weeks/week-03/slides.qmd pics/...
git commit -m "Week 3: draft Lotka–Volterra extension slides"
git push -u origin week-03-slides
```

Then open a **Pull Request** into `main` on GitHub:

https://github.com/s-peischl/QuantiativeBiology_I/pulls

Stephan (or a maintainer) reviews and merges.

### Direct push to `main` (maintainers)

Pushing to `main` triggers **Deploy Quarto Site**:

`.github/workflows/deploy-pages.yml`

After a successful run, the site updates at:

https://s-peischl.github.io/QuantiativeBiology_I/

Check progress: repo → **Actions** → **Deploy Quarto Site**.

### Commit message tips

- Prefer *why* over laundry lists: `Week 2: use real Gause Fig. 32 data`
- One logical change per commit when practical
- Never commit secrets (`.env`, tokens, credentials)

### What not to commit

Already ignored / should stay local:

- `_site/`
- `.quarto/` (except we may commit selected `_freeze/` plot caches — see below)
- `.Rhistory`, `.RData`, `.DS_Store`

---

## Important: R plots and GitHub Pages

CI currently runs:

```bash
quarto render --no-execute
```

So **R chunks are not re-run** on the server.

That means:

1. **Static images** (`![](...jpg)`) always appear.
2. **Plots from `{r}` chunks** only appear online if frozen results are committed, or if a maintainer changes CI to execute code.

For Week 2, frozen figures live under `_freeze/weeks/week-02/` and are tracked on purpose.

If you add new R figures to a deck:

```bash
# locally, with freeze enabled on that document
quarto render weeks/week-XX/slides.qmd
git add -f _freeze/weeks/week-XX
git commit -m "Week XX: freeze slide figures for Pages"
```

Or ask a maintainer to enable execution in CI (requires listing R packages the site needs).

---

## Common pitfalls

| Problem | Fix |
|---------|-----|
| Preview looks like a long webpage, not slides | Use Quarto Preview / `--to revealjs`, not Markdown preview |
| Slides suddenly render as HTML | Someone set `format:` in `_quarto.yml` or `weeks/_metadata.yml` — remove it |
| Broken image / data paths | Paths are relative to the `.qmd` file location |
| Site still shows old content | Wait for Actions to finish; hard-refresh (`Cmd+Shift+R`) |
| Push rejected for `.github/workflows/...` | Token needs `workflow` scope; avoid editing workflows unless you have that permission |
| R plot missing online | Freeze locally and commit `_freeze/...`, or use a static PNG |

---

## Style conventions (keep decks consistent)

- Match existing Week 1–2 YAML / footer / navigation block
- Prefer short slides (one idea per `##`)
- Biology first, then model / code
- Link **Course outline** and **Home** in the footer
- Credit image sources (slide aside or `pics/README.md`)
- Use real data / citations when claiming empirical content

Templates:

- `templates/slides-template.qmd`
- `templates/notebook-template.qmd`
- `templates/assignment-template.qmd`

---

## Quick checklist before opening a PR

- [ ] Edited the right week under `weeks/week-XX/`
- [ ] Previewed slides with Quarto (Reveal.js), not Markdown preview
- [ ] Relative links / images work
- [ ] Image credits updated if you added files under `pics/`
- [ ] No answer keys or private data committed
- [ ] If you added R plots: freeze committed or noted for maintainer
- [ ] Cleared commit message; `git status` clean except intended files

---

## Where to get help

- Quarto slides: https://quarto.org/docs/presentations/revealjs/
- Quarto projects / websites: https://quarto.org/docs/websites/
- This course outline (student-facing): [`docs/course-outline.qmd`](docs/course-outline.qmd)
- Collaborator guide on the live hub: https://s-peischl.github.io/QuantiativeBiology_I/docs/for-collaborators.html

Questions about pedagogy or week ownership → contact **Stephan Peischl**.
