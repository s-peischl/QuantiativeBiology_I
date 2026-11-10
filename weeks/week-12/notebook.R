# Woche 12 - Notebook (nur R, base R)
# Tabelle und Schluessel: zwei Jahre Rottensand einlesen, pruefen und kombinieren
# In RStudio: Working Directory = weeks/week-12, dann Zeile fuer Zeile ausfuehren.
# Quarto: notebook.qmd. Knit ohne Quarto: notebook.Rmd.

# Im Rottensand (Pfynwald, Wallis) haben Studierende der Universitaet Bern im Juli 2019 und im Juli 2024 Heuschrecken gezaehlt. Dieselben 10 x 10 m Flaechen, je vier Besuche, dazu eine Karte des Lebensraums: wie viel Gras, Kraut, offener Boden, Kies und Stein.
#
# Zwei Jahre, zwei Dateien. Heute machen Sie daraus eine Tabelle, mit der man arbeiten kann. Naechste Woche spielen wir mit Abbildungen.
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
# 1. Beide Jahre einlesen und verstehen, was eine Zeile ist.
# 2. Aus jeder Datei eine kurze Tabelle machen, mit derselben Funktion.
# 3. Pruefen, ob die Daten plausibel sind.
# 4. Die zwei Jahre kombinieren: nebeneinander und untereinander.
# 5. Eine erste Abbildung: Gleicher Plot, zwei Jahre.

# ===========================================================================
# 0 · Das Projekt
# ===========================================================================
#
# Ein Projekt ist ein Ordner. Darin liegt dieses Notebook, und daneben ein Ordner data/ mit den Rohdaten. Die Rohdaten werden nie von Hand geaendert. Jede Aenderung steht im Code.

list.files("data")

# Falls hier character(0) steht: In RStudio Session -> Set Working Directory -> To Source File Location.

# ===========================================================================
# 1 · Einlesen
# ===========================================================================

roh24 <- read.csv("data/rottensand_2024.csv")
roh19 <- read.csv("data/rottensand_2019.csv")

dim(roh24)
dim(roh19)

# Ueber 130 Spalten. Die ersten paar:

head(roh24[, 1:8], 10)

# Fuer jede Art gibt es vier Spalten, eine pro Besuch: OedCae1, OedCae2, OedCae3, OedCae4.

head(roh24[roh24$quarter == "tot", c("plot", "OedCae1", "OedCae2", "OedCae3", "OedCae4")])

# F1
# - Jeder Plot kommt fuenfmal vor (quarter = SW, NW, NE, SE, tot). Was koennte das bedeuten? Schauen Sie sich die Zeilen von Plot 3 an: roh24[roh24plot == 3, 1:8].
# - Warum haben einige Zeilen ueberall NA?
# - Welche Spalten gibt es nur in einem der beiden Jahre? Probieren Sie setdiff(names(roh19), names(roh24)).

# ===========================================================================
# 2 · Eine kurze Tabelle
# ===========================================================================
#
# Wir behalten nur die ganzen Plots (quarter == "tot"), die auch besucht wurden. Fuer jede Art nehmen wir die hoechste Zahl aus den vier Besuchen: so viele Tiere waren mindestens da.

arten <- c("OedCae", "CalIta", "OedGer", "SphCae", "PlaAlb", "ManRel")

# Hoechste Zaehlung ueber die vier Besuche, fuer jede Zeile
max_besuch <- function(d, art) {
  zaehlung <- d[, paste0(art, 1:4)]
  apply(zaehlung, 1, function(x) if (all(is.na(x))) NA else max(x, na.rm = TRUE))
}

# Alles, was wir mit einer Datei tun, packen wir in eine Funktion. Dann machen wir fuer 2019 genau dasselbe wie fuer 2024, ohne Copy-Paste.

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
    kraut   = d$forb,
    kies    = d$gravel,
    stein   = d$stone + d$rock,
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

# F2
# - Wie viele Plots gibt es pro Jahr? (nrow)
# - Statt 136 Spalten sind es jetzt 20. Was ist eine Zeile?
# - Fuegen Sie in aufbereiten eine Spalte streu = dlitter hinzu und lassen Sie den Block noch einmal laufen. In beiden Jahren ist sie jetzt da. Das ist der Vorteil einer Funktion.

# ===========================================================================
# 3 · Pruefen, bevor man plottet
# ===========================================================================
#
# Drei Fragen, bevor man einer Tabelle traut.
#
# Gibt es einen Plot doppelt? Die Plotnummer ist unser Schluessel. Sie muss eindeutig sein.

sum(duplicated(k19$plot))
sum(duplicated(k24$plot))

# Ergeben die Deckungen 100 %?

table(k19$deckung)
table(k24$deckung)

# Heissen die Lebensraeume in beiden Jahren gleich?

table(k19$habitat)
table(k24$habitat)

# F3
# - Welche Plots haben 2019 keine 100 %? Finden Sie sie mit k19[k19deckung != 100, ]. Was wuerden Sie mit diesen Plots machen?
# - Welche Lebensraum-Namen gibt es nur 2024?
# - Diese Fehler sind echt. Im Feld schreibt man schnell etwas falsch. Wichtig ist nur, dass man es findet, bevor man Schluesse zieht.

# ===========================================================================
# 4 · Kombinieren
# ===========================================================================
#
# Es gibt zwei Arten, Tabellen zu kombinieren.
#
# Nebeneinander (merge): Zeilen mit demselben Schluessel werden zusammengelegt. Jede Zeile ist ein Plot, mit den Spalten von 2019 und von 2024.

beide <- merge(k19, k24, by = "plot", suffixes = c("_2019", "_2024"))
dim(beide)
head(beide[, c("plot", "habitat_2019", "habitat_2024", "OedCae_2019", "OedCae_2024")])

# Untereinander (rbind): Die Tabellen werden gestapelt. Jede Zeile ist ein Plot in einem Jahr. Das geht nur, weil beide Tabellen dieselben Spalten haben, dank aufbereiten.

alle <- rbind(k19, k24)
dim(alle)
table(alle$jahr)

# F4
# - 2019 waren es 92 Plots, 2024 waren es 90. Warum hat beide nur 83 Zeilen?
# - Welche Plots fehlen? setdiff(k19plot, k24plot) und setdiff(k24plot, k19plot).
# - Fuer welche Frage brauchen Sie beide, fuer welche alle?
#   a) Ist Calliptamus in der Steppe haeufiger als im Wald?
#   b) Hat ein Plot, der 2019 viele Tiere hatte, 2024 auch viele?

# ===========================================================================
# 5 · Gleicher Plot, zwei Jahre
# ===========================================================================

plot(beide$OedCae_2019, beide$OedCae_2024,
     pch = 16, col = "#2980b9",
     xlab = "Anzahl 2019", ylab = "Anzahl 2024",
     main = "Oedipoda caerulescens, gleicher Plot")
abline(0, 1, lty = 2)   # Diagonale: in beiden Jahren gleich viele

# F5
# - Aendern Sie OedCae zu einer anderen Art (an beiden Stellen). Liegen die Punkte auf der Diagonale?
# - Gleicher Plot, gleiche Methode, und trotzdem oft ganz andere Zahlen. Denken Sie an Woche 9: Woher kommt der Unterschied?

# ===========================================================================
# 6 · Abspeichern
# ===========================================================================
#
# Die kombinierte Tabelle koennen Sie speichern. Aber: Die Datei ist ein Ergebnis, kein Rohdatum. Wer sie wieder braucht, laesst besser dieses Notebook noch einmal laufen.

# write.csv(alle, "data/rottensand_alle.csv", row.names = FALSE)

# F6 · Bonus
# Was muesste jemand anderes haben, um genau Ihre Abbildung aus Teil 5 noch einmal zu machen? Schreiben Sie eine kurze Liste.

# Daten: Feldpraktikum Conservation Biology, Universitaet Bern (Rottensand 2019 und 2024), mit freundlicher Genehmigung. Die Kuerzel der Beobachterinnen und Beobachter sind durch Teamcodes ersetzt.
