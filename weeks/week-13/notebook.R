# Woche 13 - Notebook (nur R, base R)
# Farbe und Form: Abbildungs-Werkstatt mit den Rottensand-Daten
# In RStudio: Working Directory = weeks/week-13, dann Zeile fuer Zeile ausfuehren.
# Quarto: notebook.qmd. Knit ohne Quarto: notebook.Rmd.

# Letzte Woche haben Sie aus zwei Dateien eine Tabelle gemacht. Heute ist Werkstatt: Wir machen aus denselben Daten Abbildungen, Schritt fuer Schritt, von langweilig bis richtig gut. Am Schluss stellen Sie Ihre eigene Frage.
#
# Jede Abbildung beantwortet eine Frage. Schreiben Sie sie sich auf, bevor Sie plotten.

# Auftrag
# 1. Eine Standard-Abbildung in vier Schritten verbessern.
# 2. Eine Karte der Plots zeichnen, dann sechs Karten auf einmal.
# 3. Eine Abbildung als Funktion schreiben und als Datei speichern.
# 4. Ihre Frage (ca. 15 min): eine Abbildung und ein Satz, was sie zeigt und was nicht.

# ===========================================================================
# 0 · Die Tabelle von letzter Woche
# ===========================================================================
#
# Dieser Block ist der Code aus Woche 12. Weil alles im Code steht, entsteht die Tabelle in einer Sekunde wieder. Einfach ausfuehren.

roh19 <- read.csv("data/rottensand_2019.csv")
roh24 <- read.csv("data/rottensand_2024.csv")

arten <- c("OedCae", "CalIta", "OedGer", "SphCae", "PlaAlb", "ManRel")
namen <- c(OedCae = "Oedipoda caerulescens", CalIta = "Calliptamus italicus",
           OedGer = "Oedipoda germanica", SphCae = "Sphingonotus caerulans",
           PlaAlb = "Platycleis albopunctata", ManRel = "Mantis religiosa")

max_besuch <- function(d, art) {
  zaehlung <- d[, paste0(art, 1:4)]
  apply(zaehlung, 1, function(x) if (all(is.na(x))) NA else max(x, na.rm = TRUE))
}

aufbereiten <- function(roh, jahr) {
  d <- roh[roh$quarter == "tot" & !is.na(roh$temp1), ]
  kurz <- data.frame(plot = d$plot, jahr = jahr, x = d$Xcoo, y = d$Ycoo,
                     habitat = d$habitat.type, temp = d$temp1,
                     boden = d$soil, gras = d$grass, kraut = d$forb,
                     kies = d$gravel, stein = d$stone + d$rock,
                     baum = d$canopy, deckung = d$cover.sum,
                     team = d$observ1)
  for (a in arten) kurz[[a]] <- max_besuch(d, a)
  kurz
}

k19 <- aufbereiten(roh19, 2019)
k24 <- aufbereiten(roh24, 2024)
beide <- merge(k19, k24, by = "plot", suffixes = c("_2019", "_2024"))
alle  <- rbind(k19, k24)

# Nur die drei grossen Lebensraeume
drei <- alle[alle$habitat %in% c("alluvial", "forest", "steppe"), ]
drei$habitat <- factor(drei$habitat, levels = c("forest", "alluvial", "steppe"))

hab_farben <- c(forest = "#1e8449", alluvial = "#5dade2", steppe = "#e5a50a")

# Zur Erinnerung: alle hat eine Zeile pro Plot und Jahr, beide eine Zeile pro Plot mit beiden Jahren nebeneinander.

# ===========================================================================
# 1 · Makeover in vier Schritten
# ===========================================================================
#
# Frage: Wo lebt Calliptamus italicus: im Wald, in der Aue oder in der Steppe?

# --- Schritt 1: Standard ---

boxplot(CalIta ~ habitat, data = drei)

# Es funktioniert. Aber wer das Bild ohne Text sieht, weiss nicht, was gezaehlt wurde.

# --- Schritt 2: Beschriftung und Farbe ---

boxplot(CalIta ~ habitat, data = drei,
        col = hab_farben,
        names = c("Wald", "Aue", "Steppe"),
        xlab = "", ylab = "Tiere pro Plot (max. von 4 Besuchen)",
        main = "Calliptamus italicus")

# --- Schritt 3: die Punkte zeigen ---
#
# Ein Boxplot versteckt, wie viele Plots es sind. Wir legen jeden Plot als Punkt darueber.

boxplot(CalIta ~ habitat, data = drei,
        col = adjustcolor(hab_farben, alpha.f = 0.35), border = "grey40",
        names = c("Wald", "Aue", "Steppe"), outline = FALSE,
        xlab = "", ylab = "Tiere pro Plot (max. von 4 Besuchen)",
        main = "Calliptamus italicus")
stripchart(CalIta ~ habitat, data = drei, add = TRUE, vertical = TRUE,
           method = "jitter", jitter = 0.15, pch = 16, cex = 0.8,
           col = hab_farben)

# --- Schritt 4: zwei Jahre nebeneinander ---

boxplot(CalIta ~ jahr + habitat, data = drei,
        col = rep(hab_farben, each = 2), border = "grey30",
        names = rep(c("2019", "2024"), 3), las = 1,
        xlab = "", ylab = "Tiere pro Plot",
        main = "Calliptamus italicus: Wald, Aue, Steppe")
abline(v = c(2.5, 4.5), col = "grey80")
mtext(c("Wald", "Aue", "Steppe"), side = 1, line = 2.5, at = c(1.5, 3.5, 5.5))

# F1
# - Aendern Sie CalIta zu einer anderen Art. Bei welcher Art ist der Unterschied zwischen Steppe und Aue am kleinsten?
# - Was zeigt Schritt 4, das Schritt 1 nicht zeigt?
# - Probieren Sie andere Farben: hab_farben <- c(forest = "darkgreen", alluvial = "steelblue", steppe = "gold"). Alle Farbnamen: colors().

# ===========================================================================
# 2 · Eine Karte
# ===========================================================================
#
# Jeder Plot hat Koordinaten. Damit koennen wir eine Karte zeichnen: Farbe = Lebensraum, Groesse = Anzahl Tiere.

art  <- "OedCae"   # bitte aendern
jahr <- 2024       # bitte aendern

d <- drei[drei$jahr == jahr, ]
plot(d$x, d$y, asp = 1,
     pch = 21, bg = adjustcolor(hab_farben[as.character(d$habitat)], 0.8), col = "grey30",
     cex = 0.6 + sqrt(d[[art]]) / 1.5,
     xlab = "Ost (m)", ylab = "Nord (m)",
     main = paste(namen[art], jahr))
legend("topleft", legend = c("Wald", "Aue", "Steppe"),
       pt.bg = hab_farben, pch = 21, bty = "n")

# Die Plots liegen in einem Band entlang der Rhône. Grosse Kreise: viele Tiere.

# F2
# - Setzen Sie jahr <- 2019. Sieht die Karte gleich aus?
# - Warum sqrt() fuer die Groesse? Probieren Sie cex = d[[art]] / 3 und vergleichen Sie.

# --- Sechs Karten auf einmal ---
#
# Mit einer Schleife zeichnen wir fuer jede Art eine kleine Karte. Gleiche Achsen, gleiche Farben: So kann man die Bilder direkt vergleichen.

d <- drei[drei$jahr == 2024, ]
par(mfrow = c(3, 2), mar = c(1, 1, 2, 1))
for (a in arten) {
  plot(d$x, d$y, asp = 1, axes = FALSE, xlab = "", ylab = "",
       pch = 21, bg = adjustcolor(hab_farben[as.character(d$habitat)], 0.8), col = "grey30",
       cex = 0.4 + sqrt(d[[a]]) / 1.5,
       main = namen[a], font.main = 3)
  box(col = "grey85")
}
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2))

# F3
# - Welche Arten sind fast ueberall, welche nur an einigen Stellen?
# - Welche zwei Arten haben das aehnlichste Muster?

# --- Gekommen, geblieben, verschwunden ---
#
# Mit beide koennen wir jeden Plot in beiden Jahren ansehen. Wo ist eine Art neu aufgetaucht?

art <- "SphCae"   # bitte aendern

vorher  <- beide[[paste0(art, "_2019")]] > 0
nachher <- beide[[paste0(art, "_2024")]] > 0
status <- ifelse(vorher & nachher, "geblieben",
          ifelse(nachher, "neu",
          ifelse(vorher, "verschwunden", "nie")))
status_farben <- c(geblieben = "#2471a3", neu = "#28b463",
                   verschwunden = "#cb4335", nie = "grey85")

plot(beide$x_2024, beide$y_2024, asp = 1, pch = 21, cex = 1.6,
     bg = status_farben[status], col = "grey40",
     xlab = "Ost (m)", ylab = "Nord (m)",
     main = paste(namen[art], "2019 -> 2024"))
legend("topleft", legend = names(status_farben), pt.bg = status_farben,
       pch = 21, pt.cex = 1.4, bty = "n")
table(status)

# F4
# - In wie vielen Plots ist Sphingonotus neu? Ist sie wirklich haeufiger geworden, oder kann das auch an der Zaehlung liegen (Woche 9)?
# - Probieren Sie eine Art, die eher verschwunden ist.

# ===========================================================================
# 3 · Reproduzierbar: eine Funktion und eine Datei
# ===========================================================================
#
# Wenn Sie eine Abbildung moegen, machen Sie eine Funktion daraus. Dann ist jede neue Variante eine Zeile.

karte <- function(art, jahr) {
  d <- drei[drei$jahr == jahr, ]
  plot(d$x, d$y, asp = 1,
       pch = 21, bg = adjustcolor(hab_farben[as.character(d$habitat)], 0.8), col = "grey30",
       cex = 0.6 + sqrt(d[[art]]) / 1.5,
       xlab = "Ost (m)", ylab = "Nord (m)",
       main = paste(namen[art], jahr))
}

karte("CalIta", 2019)

# Und so landet sie als Datei im Projektordner, jedes Mal genau gleich:

# png("karte_calliptamus_2019.png", width = 1600, height = 900, res = 200)
# karte("CalIta", 2019)
# dev.off()

# F5
# Speichern Sie Ihre Lieblingskarte als PNG. Oeffnen Sie die Datei. Naechstes Jahr kommen neue Daten: Was muessten Sie aendern, um dieselbe Abbildung fuer 2025 zu machen?

# ===========================================================================
# 4 · Ihre Frage (ca. 15 min)
# ===========================================================================
#
# Waehlen Sie eine Frage, machen Sie eine Abbildung und schreiben Sie einen Satz: Was zeigt sie, und was zeigt sie nicht? Zeigen Sie das Ergebnis der Assistenz.
#
# | Frage | Tipp |
# |---|---|
# | Welche zwei Arten kommen oft zusammen vor? | plot(alleCalIta, alleOedGer) oder cor(alle[, arten]) |
# | Moegen die blaufluegeligen Arten offenen Boden? | plot(alleboden + allekies + allestein, alleSphCae) |
# | Zaehlt man bei Hitze mehr? | plot(alletemp, alleCalIta) |
# | Zaehlen Teams verschieden? | boxplot(CalIta ~ team, data = k24, las = 2) |
# | Wo stehen Baeume, und wer meidet sie? | plot(allebaum, alleOedCae) |
# | Wie viele Arten pro Plot? | allen_arten <- rowSums(alle[, arten] > 0), dann eine Karte |
# | Ihre eigene Frage | |

# F6
# Ihre Abbildung, ein Satz: "Die Abbildung zeigt ... . Sie zeigt nicht, ... ."

# --- Bonus · dasselbe mit ggplot2 ---
#
# Viele Abbildungen in Publikationen sind mit dem Paket ggplot2 gemacht. Die Idee: Man beschreibt, welche Spalte auf welche Achse, Farbe oder Groesse kommt, und ggplot2 zeichnet. Ein Bild pro Art und Jahr ist dann eine einzige Zeile (facet_grid).
#
# Falls das Paket fehlt: install.packages("ggplot2").

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)

  # Lange Tabelle: eine Zeile pro Plot, Jahr und Art
  lang <- do.call(rbind, lapply(arten, function(a)
    data.frame(drei[, c("plot", "jahr", "x", "y", "habitat")],
               art = namen[a], anzahl = drei[[a]])))

  ggplot(lang, aes(x, y, size = anzahl, colour = habitat)) +
    geom_point(alpha = 0.7) +
    scale_colour_manual(values = hab_farben) +
    scale_size_area(max_size = 6) +
    facet_grid(art ~ jahr) +
    coord_equal() +
    theme_void() +
    theme(strip.text.y = element_text(face = "italic", angle = 0, hjust = 0))
}

# Daten: Feldpraktikum Conservation Biology, Universitaet Bern (Rottensand 2019 und 2024), mit freundlicher Genehmigung. Die Kuerzel der Beobachterinnen und Beobachter sind durch Teamcodes ersetzt.
