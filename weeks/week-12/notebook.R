# Woche 12 - Notebook (nur R)
# Tabelle und Schluessel: zwei Jahre Rottensand kombinieren und mit ggplot2 Abbildungen bauen
# In RStudio: Working Directory = weeks/week-12, dann Zeile fuer Zeile ausfuehren.
# Quarto: notebook.qmd. Knit ohne Quarto: notebook.Rmd.

# Im Rottensand (Pfynwald, Wallis) haben Studierende der Universitaet Bern im Juli 2019 und im Juli 2024 Heuschrecken gezaehlt. Dieselben 10 x 10 m Flaechen, je vier Besuche, dazu eine Karte des Lebensraums: wie viel Gras, Kraut, offener Boden, Kies und Stein.
#
# Zwei Jahre, zwei Dateien. Zuerst machen Sie daraus eine Tabelle. Dann kommt der spannende Teil: Mit dieser Tabelle und ggplot2 bauen Sie in wenigen Zeilen Abbildungen, fuer die man in Excel einen Nachmittag klicken wuerde.
#
# Die Arten (Kuerzel in den Daten):
#
# | Kuerzel | Art | |
# |---|---|---|
# | OedCae | Oedipoda caerulescens | Blaufluegelige Oedlandschrecke |
# | CalIta | Calliptamus italicus | Italienische Schoenschrecke |
# | OedGer | Oedipoda germanica | Rotfluegelige Oedlandschrecke |
# | SphCae | Sphingonotus caerulans | Blaufluegelige Sandschrecke |
# | PlaAlb | Platycleis albopunctata | Westliche Beissschrecke |
# | ManRel | Mantis religiosa | Gottesanbeterin |

# Auftrag
# 1. Beide Jahre einlesen und eine Tabelle daraus machen (ca. 15 min).
# 2. Die Tabelle in die lange Form bringen: eine Zeile pro Plot, Jahr und Art.
# 3. ggplot-Spielplatz (ca. 30 min): Abbildungen bauen, veraendern, ausprobieren. Das ist der Hauptteil.

# ===========================================================================
# 0 · Das Projekt
# ===========================================================================
#
# Ein Projekt ist ein Ordner. Darin liegt dieses Notebook, und daneben ein Ordner data/ mit den Rohdaten. Die Rohdaten werden nie von Hand geaendert. Jede Aenderung steht im Code.

list.files("data")

# Falls hier character(0) steht: In RStudio Session -> Set Working Directory -> To Source File Location.
#
# Heute brauchen wir das Paket ggplot2. Falls der naechste Block einen Fehler gibt, einmal install.packages("ggplot2") ausfuehren.

library(ggplot2)

# ===========================================================================
# 1 · Einlesen
# ===========================================================================

roh24 <- read.csv("data/rottensand_2024.csv")
roh19 <- read.csv("data/rottensand_2019.csv")

dim(roh24)
dim(roh19)

# Ueber 130 Spalten. Fuer jede Art gibt es vier Spalten, eine pro Besuch: OedCae1 bis OedCae4.

head(roh24[roh24$quarter == "tot", c("plot", "quarter", "habitat.type", "OedCae1", "OedCae2", "OedCae3", "OedCae4")])

# F1
# - Jeder Plot kommt fuenfmal vor (quarter = SW, NW, NE, SE, tot). Was koennte das bedeuten? Schauen Sie sich Plot 3 an: roh24[roh24plot == 3, 1:8].
# - Warum haben einige Zeilen ueberall NA?

# ===========================================================================
# 2 · Eine Funktion fuer beide Jahre
# ===========================================================================
#
# Wir behalten nur die ganzen, besuchten Plots. Fuer jede Art nehmen wir die hoechste Zahl aus den vier Besuchen. Alles steckt in einer Funktion: So machen wir fuer 2019 genau dasselbe wie fuer 2024, ohne Copy-Paste.

arten <- c("OedCae", "CalIta", "OedGer", "SphCae", "PlaAlb", "ManRel")

# Hoechste Zaehlung ueber die vier Besuche, fuer jede Zeile
max_besuch <- function(d, art) {
  zaehlung <- d[, paste0(art, 1:4)]
  apply(zaehlung, 1, function(x) if (all(is.na(x))) NA else max(x, na.rm = TRUE))
}

aufbereiten <- function(roh, jahr) {
  d <- roh[roh$quarter == "tot" & !is.na(roh$temp1), ]   # ganze, besuchte Plots
  kurz <- data.frame(
    plot    = d$plot,
    jahr    = jahr,
    x       = d$Xcoo,             # Koordinaten (Schweizer Landeskoordinaten, m)
    y       = d$Ycoo,
    habitat = d$habitat.type,
    temp    = d$temp1,            # Temperatur beim ersten Besuch
    boden   = d$soil,             # Deckung in Prozent
    gras    = d$grass,
    kies    = d$gravel,
    baum    = d$canopy,
    deckung = d$cover.sum,        # Summe aller Deckungen, sollte 100 sein
    team    = d$observ1           # wer beim ersten Besuch gezaehlt hat
  )
  for (a in arten) {
    kurz[[a]] <- max_besuch(d, a)
  }
  kurz
}

k24 <- aufbereiten(roh24, 2024)
k19 <- aufbereiten(roh19, 2019)
head(k24)

# ===========================================================================
# 3 · Pruefen und kombinieren
# ===========================================================================
#
# Drei schnelle Fragen an jede Tabelle:

sum(duplicated(k19$plot)); sum(duplicated(k24$plot))   # Schluessel doppelt?
table(k19$deckung)                                      # Deckung = 100?
table(k19$habitat); table(k24$habitat)                  # gleiche Namen?

# Die zwei Jahre untereinander stapeln. Das geht, weil aufbereiten beiden Tabellen dieselben Spalten gibt:

alle <- rbind(k19, k24)

# Entscheidung, im Code festgehalten: nur die drei grossen Lebensraeume,
# mit deutschen Namen. Die 4 Plots mit neuen Namen 2024 fallen weg.
alle <- alle[alle$habitat %in% c("forest", "alluvial", "steppe"), ]
alle$habitat <- factor(alle$habitat, levels = c("forest", "alluvial", "steppe"),
                       labels = c("Wald", "Aue", "Steppe"))
table(alle$jahr, alle$habitat)

# F2
# - Welche Plots haben 2019 keine 100 % Deckung? k19[k19deckung != 100, ]
# - Welche Lebensraum-Namen gibt es nur 2024? Was haben wir mit diesen Plots gemacht, und wo steht das?

# ===========================================================================
# 4 · Die lange Tabelle
# ===========================================================================
#
# alle hat fuer jede Art eine eigene Spalte. Fuer Abbildungen ist eine andere Form praktischer: eine Zeile pro Plot, Jahr und Art, und die Art steht in einer Spalte. Dann kann jede Spalte zu einer Achse, einer Farbe oder einem eigenen Bild werden.

namen <- c(OedCae = "Oedipoda caerulescens", CalIta = "Calliptamus italicus",
           OedGer = "Oedipoda germanica", SphCae = "Sphingonotus caerulans",
           PlaAlb = "Platycleis albopunctata", ManRel = "Mantis religiosa")

lang <- NULL
for (a in arten) {
  stueck <- alle[, c("plot", "jahr", "x", "y", "habitat", "temp", "boden", "gras", "team")]
  stueck$art <- namen[a]
  stueck$anzahl <- alle[[a]]
  lang <- rbind(lang, stueck)
}

dim(lang)
head(lang)

# F3
# - Wie viele Zeilen haben alle und lang? (nrow) Warum hat lang genau 6-mal so viele?
# - Was ist jetzt eine Zeile?

# ===========================================================================
# 5 · ggplot-Spielplatz
# ===========================================================================
#
# Jede ggplot-Abbildung hat drei Teile:
#
# 1. Daten: ggplot(lang, ...)
# 2. Zuordnung (aes): welche Spalte auf die x-Achse, die y-Achse, die Farbe, die Groesse kommt
# 3. Geometrie (geom_...): Punkte, Boxen, Linien, Balken
#
# Die Teile werden mit + verbunden. Wir bauen eine Abbildung in fuenf Schritten.

# --- Schritt 1: Boxen ---

ggplot(lang, aes(x = habitat, y = anzahl)) +
  geom_boxplot()

# --- Schritt 2: jeder Plot ein Punkt ---

ggplot(lang, aes(x = habitat, y = anzahl, colour = habitat)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.5)

# --- Schritt 3: ein Bild pro Art ---
#
# Ein Befehl mehr, und jede Art bekommt ihr eigenes Bild. Das ist die Staerke der langen Tabelle.

ggplot(lang, aes(x = habitat, y = anzahl, colour = habitat)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  facet_wrap(~ art, scales = "free_y")

# --- Schritt 4: schoen machen ---

farben <- c(Wald = "#1e8449", Aue = "#5dade2", Steppe = "#e5a50a")

ggplot(lang, aes(x = habitat, y = anzahl, colour = habitat)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  facet_wrap(~ art, scales = "free_y") +
  scale_colour_manual(values = farben, guide = "none") +
  labs(x = NULL, y = "Tiere pro Plot (max. von 4 Besuchen)",
       title = "Alle sechs Arten sind in der Steppe am haeufigsten") +
  theme_minimal(base_size = 13) +
  theme(strip.text = element_text(face = "italic"))

# --- Schritt 5: dieselben Daten als Karte ---
#
# Nur die Zuordnung aendert sich: x und y sind jetzt die Koordinaten, die Groesse ist die Anzahl.

ggplot(lang, aes(x = x, y = y, size = anzahl, colour = habitat)) +
  geom_point(alpha = 0.6) +
  facet_grid(jahr ~ art) +
  scale_colour_manual(values = farben) +
  scale_size_area(max_size = 3) +
  coord_equal() +
  theme_void() +
  theme(strip.text.x = element_text(face = "italic", size = 8), legend.position = "bottom")

# Zwoelf Karten, sechs Arten mal zwei Jahre, in acht Zeilen. In Excel waeren das zwoelf einzelne Diagramme, und bei neuen Daten muesste man alle zwoelf neu klicken.

# F4 · Veraendern Sie je **eine** Sache
# Nehmen Sie den Code aus Schritt 4 und probieren Sie:
#
# 1. y = anzahl aendern zu y = log1p(anzahl). Was wird besser sichtbar?
# 2. facet_wrap(~ art) aendern zu facet_grid(art ~ jahr).
# 3. colour = habitat aendern zu colour = factor(jahr) (und die Zeile scale_colour_manual loeschen).
# 4. geom_boxplot ersetzen durch geom_violin.
# 5. theme_minimal() ersetzen durch theme_dark() oder theme_classic().

# --- Eigene Abbildungen ---
#
# Ein paar Ideen zum Ausprobieren. Starten Sie mit einer Vorlage und veraendern Sie sie.
#
# Moegen die Heuschrecken offenen Boden?

ggplot(lang, aes(x = boden, y = anzahl, colour = habitat)) +
  geom_point(alpha = 0.6) +
  geom_smooth(aes(group = 1), method = "loess", colour = "black", se = FALSE) +
  facet_wrap(~ art, scales = "free_y") +
  scale_colour_manual(values = farben) +
  labs(x = "Offener Boden (%)", y = "Tiere pro Plot") +
  theme_minimal()

# Zaehlt man bei Hitze mehr?

ggplot(lang, aes(x = temp, y = anzahl)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ art, scales = "free_y") +
  labs(x = "Temperatur beim ersten Besuch (Grad C)", y = "Tiere pro Plot") +
  theme_minimal()

# Gleicher Plot, zwei Jahre. Dafuer brauchen wir die Jahre nebeneinander, mit merge ueber den Schluessel plot:

l19 <- lang[lang$jahr == 2019, c("plot", "art", "anzahl")]
l24 <- lang[lang$jahr == 2024, c("plot", "art", "anzahl", "habitat")]
beide <- merge(l19, l24, by = c("plot", "art"), suffixes = c("_2019", "_2024"))

ggplot(beide, aes(x = anzahl_2019, y = anzahl_2024, colour = habitat)) +
  geom_abline(linetype = "dashed", colour = "grey50") +
  geom_jitter(width = 0.2, height = 0.2, alpha = 0.7) +
  facet_wrap(~ art, scales = "free") +
  scale_colour_manual(values = farben) +
  labs(x = "Anzahl 2019", y = "Anzahl 2024") +
  theme_minimal()

# F5 · Ihre Abbildung
# 1. Waehlen Sie eine Frage (Ideen oben, oder eine eigene) und bauen Sie eine Abbildung dazu.
# 2. Geben Sie ihr einen Titel, der die Aussage sagt, nicht nur das Thema.
# 3. Speichern Sie sie als Datei: ggsave("meine_abbildung.png", width = 8, height = 5) direkt nach dem Plot.
# 4. Was zeigt die Abbildung nicht? Ein Satz.

# Warum nicht Excel?
# - Neue Daten 2025? Eine Zeile read.csv mehr, und alle Abbildungen entstehen neu.
# - Jeder Schritt steht im Code: Wer Ihr Notebook laufen laesst, bekommt dieselbe Abbildung.
# - Ein Wort aendern (facet_wrap, colour, geom_violin) statt jedes Diagramm neu zu klicken.

# Daten: Feldpraktikum Conservation Biology, Universitaet Bern (Rottensand 2019 und 2024), mit freundlicher Genehmigung. Die Kuerzel der Beobachterinnen und Beobachter sind durch Teamcodes ersetzt.
