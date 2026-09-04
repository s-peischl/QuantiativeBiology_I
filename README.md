# Quantitative Biologie I — Leitfaden für Mitwirkende

Lehrmaterialien für **Quantitative Biologie I** (Brückenkurs).  
Live-Website: **https://s-peischl.github.io/QuantiativeBiology_I/**  
Repository: **https://github.com/s-peischl/QuantiativeBiology_I**

Diese README erklärt, wie Mitwirkende Folien, Notebooks und Aufgaben mit **Quarto** bearbeiten und Änderungen anschliessend über **GitHub** veröffentlichen.

---

## Kursbogen (Kontext)

**Ökologie → Evolution (deterministisch → zufällig) → Mikrobiom (Ökologie mit Zufälligkeit)**

| Wochen | Schwerpunkt |
|------:|-------|
| 1 | Einstieg — Bajau → Tibeter:innen |
| 2–4 | Ökologie |
| 5–8 | Evolution (deterministisch) |
| 9–10 | Evolution (zufällig) |
| 11–13 | Mikrobiom (laden → visualisieren) |
| 14 | Projekt |

Die massgeblichen Materialien befinden sich unter `weeks/week-XX/`, nicht in den älteren Verzeichnisbäumen `modules/.../weeks/...`.

---

## Erforderliche Installationen

1. **Git**
2. **Quarto** — https://quarto.org/docs/get-started/
3. **R** (für Notebooks / ausführbare Folien-Chunks) — https://cran.r-project.org/
4. Ein Editor:
   - **RStudio** (Quarto-Vorschau integriert) oder
   - **VS Code / Cursor** mit der Quarto-Erweiterung

Versionen prüfen:

```bash
quarto --version
R --version
git --version
```

Optional: Bei Verwendung der in RStudio enthaltenen Quarto-Version unter macOS befindet sich die Binärdatei häufig hier:

```text
/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto
```

Dafür kann ein Alias eingerichtet werden; alternativ Quarto eigenständig installieren und zum `PATH` hinzufügen.

---

## Projekt klonen und öffnen

```bash
git clone https://github.com/s-peischl/QuantiativeBiology_I.git
cd QuantiativeBiology_I
```

Den **Ordner** in RStudio / VS Code / Cursor öffnen (nicht nur eine einzelne Datei). Quarto benötigt das Projektstammverzeichnis, damit `_quarto.yml`, Pfade wie `../../pics/...` und das Rendern der Website funktionieren.

---

## Repository-Übersicht

```text
.
├── README.md                 ← dieser Leitfaden
├── index.qmd                 ← Startseite
├── _quarto.yml               ← Website-Konfiguration (Navigation, Renderumfang)
├── styles.scss               ← gemeinsame HTML-Gestaltung
├── docs/
│   ├── course-outline.qmd    ← Semesterplan (Studierende)
│   └── for-collaborators.qmd ← entsprechender Leitfaden auf der Live-Website
├── weeks/
│   ├── _metadata.yml         ← gemeinsame Standardwerte (hier KEIN Format setzen)
│   └── week-01 … week-14/
│       ├── slides.qmd        ← Reveal.js-Foliensatz
│       ├── notebook.qmd      ← Notebook für Studierende
│       └── data/             ← wochenbezogene CSVs (bei Bedarf)
├── pics/                     ← Bilder (Nachweise in pics/README.md)
├── templates/                ← Vorlagen für neue Wochen
├── modules/                  ← nur übergeordnete Modulnotizen (keine Wochenquellen)
└── .github/workflows/        ← Bereitstellung über GitHub Pages
```

**Faustregel:** `weeks/week-XX/*.qmd` bearbeiten. Wocheninhalte nicht unter `modules/` neu anlegen.

---

## Folien bearbeiten (Quarto + Reveal.js)

### Zu bearbeitende Datei

```text
weeks/week-XX/slides.qmd
```

Jeder Foliensatz beginnt mit YAML, das Reveal.js **deklarieren muss**:

```yaml
---
title: "Week X — Title"
subtitle: "…"
author: "Stephan Peischl, Loraine Hablützel und Emma Ochsner"
format:
  revealjs:
    theme: simple
    slide-number: true
    embed-resources: true
    # … keep the other revealjs options from an existing week
---
```

**Wichtig:** In `_quarto.yml` auf Projektebene **kein** `format: html` und in `weeks/_metadata.yml` **kein** `format:` ergänzen. Dies zwingt alle Wochendokumente in ein Format und macht die Foliensätze unbrauchbar.

### Folienstruktur

- Eine Folie ist eine Überschrift der Ebene 2: `## Folientitel`
- Die horizontale Linie `---` kann Hauptabschnitte trennen
- Aufzählungen, Tabellen, Mathematik und Code-Chunks funktionieren wie in Quarto Markdown

Beispiele:

```markdown
## Learning goals

- Goal 1
- Goal 2

## An equation

$$
N_{t+1} = N_t + (r N_t - a N_t P_t)
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

### R-Code auf Folien

```markdown
```{r}
#| fig-height: 4
#| fig-width: 7
alone <- read.csv("data/paramecium_alone.csv")
plot(alone$day, alone$paramecium, type = "b")
```
```

Pfade in Chunks sind relativ zum Ordner der `.qmd`-Datei (`weeks/week-02/`); `data/...` bedeutet daher `weeks/week-02/data/...`.

### Folien korrekt in der Vorschau anzeigen

Die Folien verwenden **Reveal.js**, nicht eine normale Markdown-Vorschau.

**RStudio:** `slides.qmd` öffnen → **Render** / **Quarto Preview**.

**Terminal:**

```bash
quarto preview weeks/week-02/slides.qmd
# or explicitly:
quarto render weeks/week-02/slides.qmd --to revealjs
```

Anschliessend öffnen:

```text
_site/weeks/week-02/slides.html
```

Tastatur nach dem Öffnen: `←` `→` navigieren · `M` Menü · `Esc` Übersicht · `F` Vollbild · `S` Vortragsnotizen (falls aktiviert).

**Nicht** auf die einfache Markdown-Vorschau des Editors verlassen — sie zeigt ein Dokument, keinen Foliensatz.

### Neue Woche aus einer Vorlage

```bash
cp templates/slides-template.qmd weeks/week-03/slides.qmd
# also notebook template as needed
```

Danach Titel, Wochennummer, Navigationslinks am Ende und Inhalte aktualisieren.

---

## Notebooks bearbeiten

| Datei | Zielgruppe | Format |
|------|----------|--------|
| `weeks/week-XX/notebook.qmd` | Unterricht / Praktikum | HTML |

Vorschau:

```bash
quarto preview weeks/week-02/notebook.qmd
```

Anweisungen für Studierende klar formulieren; Lösungen bei Bedarf in einer separaten Datei oder einem privaten Branch ablegen (Lösungsschlüssel nur absichtlich nach `main` committen).

---

## Bilder und Daten

### Bilder

- Kursbilder in `pics/` ablegen (Unterordner wie `pics/bajau/`, `pics/organisms/` sind geeignet).
- Von einer Wochendatei aus lautet der relative Pfad üblicherweise `../../pics/...`.
- Lizenzen in `pics/README.md` dokumentieren (für Wikimedia-/CC-Material erforderlich).
- Offen lizenzierte Bilder bevorzugen; private Fotos erfordern eine Genehmigung.

### Daten

- Wochenspezifische CSVs gehören nach `weeks/week-XX/data/`.
- Quellen in der `README.md` dieses Ordners dokumentieren (siehe Gause-Daten aus Woche 2).

---

## Gesamte Website lokal rendern

Aus dem Projektstammverzeichnis:

```bash
quarto render
```

Die Ausgabe wird nach `_site/` geschrieben (von Git ignoriert). Die öffentliche Website wird über GitHub Actions auf dieselbe Weise erstellt.

---

## GitHub-Arbeitsablauf (Änderungen online veröffentlichen)

### Branches (für Mitwirkende empfohlen)

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

Danach auf GitHub einen **Pull Request** nach `main` öffnen:

https://github.com/s-peischl/QuantiativeBiology_I/pulls

Stephan (oder eine betreuende Person) prüft und mergt die Änderungen.

### Direkter Push nach `main` (Betreuende)

Ein Push nach `main` löst **Deploy Quarto Site** aus:

`.github/workflows/deploy-pages.yml`

Nach erfolgreicher Ausführung wird die Website hier aktualisiert:

https://s-peischl.github.io/QuantiativeBiology_I/

Fortschritt prüfen: Repository → **Actions** → **Deploy Quarto Site**.

### Tipps für Commit-Nachrichten

- Das *Warum* ist Aufzählungen vorzuziehen: `Week 2: use real Gause Fig. 32 data`
- Wenn praktikabel, eine logische Änderung pro Commit
- Niemals Geheimnisse committen (`.env`, Tokens, Zugangsdaten)

### Was nicht committet werden soll

Bereits ignoriert / sollte lokal bleiben:

- `_site/`
- `.quarto/` (except we may commit selected `_freeze/` plot caches — see below)
- `.Rhistory`, `.RData`, `.DS_Store`

---

## Wichtig: R-Grafiken und GitHub Pages

CI führt derzeit Folgendes aus:

```bash
quarto render --no-execute
```

Somit werden **R-Chunks auf dem Server nicht erneut ausgeführt**.

Das bedeutet:

1. **Statische Bilder** (`![](...jpg)`) werden immer angezeigt.
2. **Grafiken aus `{r}`-Chunks** erscheinen online nur, wenn eingefrorene Ergebnisse committet sind oder CI durch eine betreuende Person zur Codeausführung geändert wird.

Für Woche 2 befinden sich eingefrorene Abbildungen unter `_freeze/weeks/week-02/` und werden bewusst versioniert.

Beim Hinzufügen neuer R-Abbildungen zu einem Foliensatz:

```bash
# locally, with freeze enabled on that document
quarto render weeks/week-XX/slides.qmd
git add -f _freeze/weeks/week-XX
git commit -m "Week XX: freeze slide figures for Pages"
```

Alternativ eine betreuende Person bitten, die Ausführung in CI zu aktivieren (dafür müssen die von der Website benötigten R-Pakete aufgeführt werden).

---

## Häufige Fallstricke

| Problem | Lösung |
|---------|-----|
| Vorschau zeigt eine lange Webseite statt Folien | Quarto Preview / `--to revealjs` statt Markdown-Vorschau verwenden |
| Folien werden plötzlich als HTML gerendert | `format:` wurde in `_quarto.yml` oder `weeks/_metadata.yml` gesetzt — entfernen |
| Defekte Bild-/Datenpfade | Pfade sind relativ zum Speicherort der `.qmd`-Datei |
| Website zeigt weiterhin alte Inhalte | Abschluss von Actions abwarten; vollständig neu laden (`Cmd+Shift+R`) |
| Push für `.github/workflows/...` abgelehnt | Token benötigt den Bereich `workflow`; Workflows nur mit entsprechender Berechtigung bearbeiten |
| R-Grafik fehlt online | Lokal einfrieren und `_freeze/...` committen oder statisches PNG verwenden |

---

## Stilkonventionen (einheitliche Foliensätze)

- YAML / Fusszeile / Navigationsblock der bestehenden Wochen 1–2 übernehmen
- Kurze Folien bevorzugen (eine Idee pro `##`)
- Zuerst Biologie, danach Modell / Code
- **Kursübersicht** und **Startseite** in der Fusszeile verlinken
- Bildquellen nachweisen (Folienrand oder `pics/README.md`)
- Für empirische Aussagen reale Daten / Zitate verwenden

Vorlagen:

- `templates/slides-template.qmd`
- `templates/notebook-template.qmd`

---

## Kurzcheckliste vor dem Öffnen eines PR

- [ ] Richtige Woche unter `weeks/week-XX/` bearbeitet
- [ ] Folien mit Quarto (Reveal.js), nicht mit der Markdown-Vorschau geprüft
- [ ] Relative Links / Bilder funktionieren
- [ ] Bildnachweise aktualisiert, falls Dateien unter `pics/` ergänzt wurden
- [ ] Keine Lösungsschlüssel oder privaten Daten committet
- [ ] Bei neuen R-Grafiken: Freeze committet oder für die Betreuung vermerkt
- [ ] Klare Commit-Nachricht; `git status` zeigt nur beabsichtigte Dateien

---

## Hilfe

- Quarto-Folien: https://quarto.org/docs/presentations/revealjs/
- Quarto-Projekte / Websites: https://quarto.org/docs/websites/
- Kursübersicht für Studierende: [`docs/course-outline.qmd`](docs/course-outline.qmd)
- Leitfaden für Mitwirkende auf der Live-Plattform: https://s-peischl.github.io/QuantiativeBiology_I/docs/for-collaborators.html

Bei Fragen zu Didaktik oder Zuständigkeiten für einzelne Wochen → **Stephan Peischl** kontaktieren.
