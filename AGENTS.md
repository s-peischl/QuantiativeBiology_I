# Agent instructions — Quantitative Biologie I

Quarto course website (German) for **Quantitative Biologie I**.  
Live: https://s-peischl.github.io/QuantiativeBiology_I/  
Remote: `origin` → `https://github.com/s-peischl/QuantiativeBiology_I.git`

Human contributor docs: `README.md` and `docs/for-collaborators.qmd` (keep those in sync if you change workflows).

---

## Cross-machine workflow

Work spans multiple machines. **Git is the sync channel**; do not rely on shared local caches or editor state.

### Starting a session (any machine)

1. Open the **repo root** (not a nested file). Quarto needs `_quarto.yml` and relative paths like `../../pics/...`.
2. Sync before editing:

```bash
git checkout main
git pull origin main
git status
```

3. Prefer a feature branch for non-trivial work (`week-XX-…`).
4. Confirm tooling if you will render or freeze:

```bash
quarto --version
R --version
```

On macOS, Quarto may live inside RStudio; prefer a PATH install when possible.

### Ending a session / switching machines

1. Commit finished work (or stash only if intentionally unfinished and local-only).
2. **Push** the branch (or `main` if you are a maintainer pushing deployable changes).
3. Note anything that did **not** ship (uncommitted drafts, local plot experiments, private solution keys).
4. On the next machine: `git pull` (or check out the same branch) before continuing.

Never assume `_site/`, `.quarto/`, or uncommitted `_freeze/` from another machine exist here.

### What syncs vs what stays local

| Track / commit | Keep local (gitignored) |
|----------------|-------------------------|
| `weeks/`, `docs/`, `pics/`, `templates/`, `scripts/` | `_site/` |
| Selected `_freeze/weeks/week-XX/` (see `.gitignore`) | `.quarto/` |
| `_quarto.yml`, `styles.scss`, workflows | `.Rhistory`, `.RData`, `.DS_Store` |

After adding R figures that must appear on Pages, freeze locally and commit freeze output (see below). Updating `.gitignore` allowlists for new week freeze dirs may be required.

---

## Where to edit

| Do | Don't |
|----|--------|
| Edit `weeks/week-XX/{slides,notebook,assignment,glossary}.qmd` | Put week sources under `modules/` (legacy / notes only) |
| Add images under `pics/` + credit in `pics/README.md` (or folder CREDITS) | Set `format:` in `_quarto.yml` or `weeks/_metadata.yml` (breaks Reveal.js) |
| Put week CSVs in `weeks/week-XX/data/` + document source | Commit solution keys or private data to `main` by accident |
| New weeks from `templates/*-template.qmd` | Treat editor Markdown preview as slide preview |

Course arc: weeks 1 → 14 under `weeks/`; `modules/` is not the teaching source of truth.

---

## Render, preview, freeze

Slides are **Reveal.js** (`format: revealjs` in each `slides.qmd`). Preview with Quarto, not plain Markdown preview:

```bash
quarto preview weeks/week-XX/slides.qmd
quarto preview weeks/week-XX/notebook.qmd
quarto render   # full site → _site/
```

CI (`.github/workflows/deploy-pages.yml`) runs:

```bash
quarto render --no-execute
```

So `{r}` plots appear online only if frozen results are committed (or CI execute is intentionally enabled). Project default: `execute: freeze: auto`.

When adding/changing executed figures for Pages:

```bash
quarto render weeks/week-XX/slides.qmd
# ensure week is allowlisted in .gitignore if needed
git add -f _freeze/weeks/week-XX
git commit -m "Week XX: freeze slide figures for Pages"
```

Paths in chunks are relative to the `.qmd` directory (`data/...` → `weeks/week-XX/data/...`). Image links from weeks usually use `../../pics/...`.

---

## Content and language

- Student-facing materials are primarily **German**; match the surrounding week’s language and tone.
- Prefer short slides (one idea per `##`), biology before model/code.
- Reuse YAML, footer, and nav patterns from existing polished weeks (e.g. 1–2).
- Prefer real data/citations for empirical claims; document image licenses.

---

## Git and deploy

- Collaborators: branch → PR into `main`.
- Push to `main` triggers **Deploy Quarto Site** → GitHub Pages.
- Do not commit secrets. Do not force-push `main` unless explicitly requested.
- Commit messages: short, why-focused (e.g. `Week 2: use real Gause Fig. 32 data`).

### Before finishing agent work

- [ ] Edited the correct `weeks/week-XX/` paths
- [ ] No project-level `format:` introduced
- [ ] Relative links/images checked conceptually
- [ ] New `pics/` credited; new data documented
- [ ] New R plots: freeze committed or flagged for maintainer
- [ ] Changes pushed or clearly left uncommitted with a note for the next machine
