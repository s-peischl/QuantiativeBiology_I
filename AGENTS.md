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
| `_quarto.yml`, `styles.css`, workflows | `.Rhistory`, `.RData`, `.DS_Store` |
| | `private/skript/` (local lecture notes; do not push to `origin`) |

After adding R figures that must appear on Pages, freeze locally and commit freeze output (see below). Updating `.gitignore` allowlists for new week freeze dirs may be required.

---

## Where to edit

| Do | Don't |
|----|--------|
| Edit `weeks/week-XX/{slides,notebook,glossary}.qmd` | Put week sources outside `weeks/` |
| Add images under `pics/` + credit in `pics/README.md` (or folder CREDITS) | Set `format:` in `_quarto.yml` or `weeks/_metadata.yml` (breaks Reveal.js) |
| Put week CSVs in `weeks/week-XX/data/` + document source | Commit solution keys or private data to `main` by accident |
| New weeks from `templates/*-template.qmd` | Treat editor Markdown preview as slide preview |

Course arc: weeks 1 → 14 under `weeks/`.

### Live hub (GitHub Pages)

Only **published** weeks are built and linked. Currently: **weeks 1–9**. Later weeks stay in git. **Week 1 has slides only** (no student notebook). Week 5 student notebook is the avocado/bloodgroups notebook; week 6 notebook is the Kehlfarben/RPS parameter task; week 7 notebook (Loraine) is migration–selection with insecticide resistance in mosquitoes (Lenormand et al. 1999); week 8 is Checkpoint B (summer vs winter resistance clines, notebook in Quarto/Rmd/R). Week 9 is *Zufall und Notwendigkeit* (pond inversion, model as expectation plus binomial chance, neutral cloud/envelope, lizards with finite N); its pond photos in `pics/pond-experiment/` are cleared for the hub (Nov 2026). The week-4 **student** notebook is public; solution notebooks and solution-only slides stay local (`notebook-loesung.qmd`, `slides-loesung.qmd`). Navbar: `Start`, `Glossar`, `KI-Richtlinie`, Folien/Notebooks as `Woche N`. Module overviews are linked from the homepage, not the navbar.

Course organisation and grading live on **ILIAS**, not as hub webpages. Student PDFs: `docs/kursinfo.pdf` (rules) and `docs/kursplan.pdf` (calendar + week content), built with `scripts/render_handouts_pdf.sh`. Source for the plan: `docs/course-outline.qmd` (not rendered as HTML).

To release the next week: add it to `render:`, its `notebook.Rmd` / `notebook.R` to `resources:` (otherwise the «Andere Formate» links are dead), and the Folien/Notebooks navbar in `_quarto.yml`, then replace «folgt» links on `index.qmd` and the module overview.

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
python3 scripts/export_slide_pdfs.py
```

So `{r}` plots appear online only if frozen results are committed (or CI execute is intentionally enabled). Project default: `execute: freeze: auto`.

Slide **PDF** downloads are generated in CI from the rendered HTML (not committed). Student pages link to `weeks/week-XX/slides.pdf`. Locally:

```bash
python3 -m pip install -r scripts/requirements-pdf.txt
python3 -m playwright install chromium
quarto render --no-execute
python3 scripts/export_slide_pdfs.py
```

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
- Slide (and notebook) YAML `subtitle:` is **two nouns joined by *und*** — the *Krieg und Frieden* cadence. Examples: *Störung und Gleichgewicht*, *Beute und Räuber*. Not a topic list, not a question, not a timetable. Session timing belongs on the Übersicht slide.
- **Data vs model wording:** Data are **compared with** expectations / a null model — never «dagegen gehalten», «daran halten», or «Daten gegen HWE/Erwartung». Prefer *mit der Erwartung vergleichen*, *Daten und Erwartung*, *im Vergleich zur Erwartung*.
- Reuse YAML, footer, and nav patterns from existing polished weeks (e.g. 1–2).
- Prefer real data/citations for empirical claims; document image licenses.
- Course author credit on slides / notebooks (YAML `author:`):


```yaml
author: "Stephan Peischl, Loraine Hablützel und Emma Ochsner"
```

  Do not replace scientific citations (e.g. Peischl & Kirkpatrick) or grant PI lists with this string.

---

## How weeks 1–8 were built

Follow this when drafting or revising a week. The first eight weeks are the standard; a later week should feel like the next hour of the same course, not a new course.

Students are first-years, in parallel with a programming course. Each session is a biological question, then data or an experiment, then the mathematics that the question forces. Derivations and formal tests belong to other lectures. Say what a figure is consistent with, and what it does not prove.

Spelling is Swiss German (`ss`, not `ß`): *gross*, *Grösse*, *dass*, *Süsswasser*. Match the tone of weeks 7–8 (short sentences, smoothed wording). Plot axis labels inside R use ASCII (*Haeufigkeit*, *Suesswasser*, *Frequenz*): umlauts in `xlab`/`ylab` have broken renders.

### What they can already do

Do not re-teach this. Do not assume anything past it.

| Week | Biology | Model they leave with | New in R |
|------|---------|------------------------|----------|
| 1 | Bajau spleen, Tibetan *EPAS1* | Question → data → method. No notebook | — |
| 2 | Gause *Paramecium*, then *Didinium* | $N_{t+1}=N_t+f(N_t)$. No $\Delta t$, no ODE as the working model | `next_*()`, vector, `for`, `plot` |
| 3 | One vs two endpoints, *Pisaster*, Yellowstone | Same pipeline; stability is about the endpoint, not the start | Food web in the notebook |
| 4 | *Uta* throat colours, Checkpoint A | Payoff matrix; 2 strategies exclude, 3 can cycle. Point / oscillation / heterocline | Change entries of $A$ |
| 5 | Same lizards as genes; HapMap; avocado | HWE is the null **without** selection. Diploid genotypes | Data frames, one operation on every row |
| 6 | Sickle cell; throat-colour wrap-up | Fitness → one recursion for $p$. Constant, underdominance, overdominance; frequency dependence + plasticity $\theta$ | Turn one parameter |
| 7 | Stickleback *Eda* / sea–freshwater; mosquitoes (Lenormand 1999) | Local selection, then mixing. $F_{ST}$ | `quantile()` to filter rows |
| 8 | Neutralism, spandrels; Checkpoint B | Summer cline first, then **one** number for winter, then a biological argument | No new tool. Helpers stay folded |

Cumulative toolkit at the end of week 8: a function for one step, a vector, a loop, a base-R plot, a data frame, vectorised row maths, filtering. Student notebooks use **base graphics** through week 11. ggplot2 is for slides (`source("../slides-ggplot.R")`, `theme_slide()`) until week 12, where it is introduced to students on purpose: the long table plus ggplot is the point of weeks 12–13.

Ploidy is easy to get wrong. Weeks 5–7 are diploid where the biology is diploid (HWE, sickle cell, mosquito genotypes $w_{RR}, w_{Rr}, w_{rr}$ — the notebook was corrected to diploid on purpose). The spatial cline in week 8 is the week-7 model. From week 9 the **course** Wright–Fisher step is haploid: selection to $p'$, then $X\sim\mathrm{Binomial}(N,p')$. Say so when the simplification matters. Do not silently switch a published diploid example to haploid.

### Shape of a session

- Week 1: two lecture halves, no notebook.
- Weeks 2, 3, 5, 6, 7: about 45 min lecture, then 45 min notebook.
- Checkpoint weeks (4, 8, and later 11, 14): short intro, notebook, then TAs walk the room. Not a board presentation.
- Slides open with **Übersicht** (week number, date, time split), then **Lernziele** as *Nach heute können Sie …* with numbered verbs. Biology, then model, then code. One idea per `##`.
- The YAML `subtitle` is the same on the slides and the notebook (*Strategie und Fitness*, *Sommer und Winter*). Timing stays on the Übersicht slide.
- State the pipeline in the open: experiment → observation → model → code. Parameter tables have symbol, meaning, constraint, and the value used in class.
- A rewrite has already dropped experiment slides that the lecture needed. Diff against the previous deck before replacing it, and put the biology back.
- New terms go in `docs/glossary.qmd`. Week 1’s `glossary.qmd` only redirects there.
- Comics live in `pics/comics/`. If the wording changes, change the SVG labels too.
- Uni Bern research callout: `::: {.unibe}` (kicker comes from `weeks/print.css`).

### Notebooks

The notebook is the same story as the slides, with the code in the students’ hands. Weeks 5–8 ship **three files of one task**: `notebook.qmd`, `notebook.Rmd`, `notebook.R`. Change all three in the same edit. A collaborator commit titled *Vorschlag* is a draft: keep it only if it still answers the lecture’s question, then sync the other two formats and the slide closer that lists the notebook steps. Do not leave `notebook.qmd` on a different organism or a different question from `notebook.Rmd`.

Pattern that worked:

- Opening prose: the biological question, what each column means, and what every figure’s axes, colours, and shapes are. Same axes for every plot in the week. A student who only looks at the figures should still learn something.
- Section 0 is “run this”: data plus helpers in a folded chunk (*nicht verändern*). Later chunks assume it has been run.
- Tasks are `::: {.callout-tip}` and numbered in order (`F1`, `F2`, …). Each task changes **one** thing. Say which number to edit.
- Notebooks the room can finish. Week 8 was cut to one model chunk and three tasks after a longer draft. If a block is optional, mark it bonus.
- `execute: freeze: false` and `echo: true` on notebooks (the code is the lesson). `embed-resources: true` and `lang: de` from week 5 on. Slides: `freeze: auto`; `echo: false` unless the chunk itself is being read (week 2).
- Decimal point, not comma (`0.02`).
- Real data: citation plus `weeks/week-XX/data/README.md`. Unpublished teaching extracts need the owners’ permission in that README. Invented series are labelled in the notebook (*Kursdaten, erfunden*), as in week 8.
- The student file does not contain the answer. Week 4 solution slides and the solution notebook are gitignored (`*-loesung.qmd`). Checkpoint keys live in `ta-merkblatt.qmd`, which is not linked from student pages or the navbar.

### Checkpoints A and B

Pass/fail is attendance and a conversation, at least 3 of 4 checkpoints. Teams of up to four. No homework. The TA comes to the group.

The task is **one question**, answered with **one figure**, in one or two minutes. The path is fixed: fit or explore the first case, change a single parameter for the second case, then argue biologically which change is plausible. Week 8: summer cline first, winter by changing either $s$ or $m$, then why it has to be selection (mosquitoes fly less in winter, so a larger $m$ is the wrong story). Several parameter pairs can match; the biology decides.

The TA sheet states what “bestanden” means, the expected range (not a single exact value), and the usual failures (both knobs moved at once, comma decimal, helper chunk not run, wrong distance read). Exact numbers are not required.

---

## Git and deploy

- Collaborators: branch → PR into `main`.
- Push to `main` triggers **Deploy Quarto Site** → GitHub Pages.
- Do not commit secrets. Do not force-push `main` unless explicitly requested.
- Commit messages: short, why-focused (e.g. `Week 2: use real Gause Fig. 32 data`).

### Before finishing agent work

- [ ] Edited the correct `weeks/week-XX/` paths
- [ ] Notebook still answers the same question as the slides; `notebook.Rmd` and `notebook.R` match `notebook.qmd`
- [ ] No new R tool beyond the one this week introduces; nothing from weeks 1–8 re-taught from scratch
- [ ] Tasks change one thing at a time; the answer is not in the student file
- [ ] No project-level `format:` introduced
- [ ] Relative links/images checked conceptually
- [ ] New `pics/` credited; new data documented (permission or *erfunden*)
- [ ] New R plots: freeze committed or flagged for maintainer
- [ ] Changes pushed or clearly left uncommitted with a note for the next machine
