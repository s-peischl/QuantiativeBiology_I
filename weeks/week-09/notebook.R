# Woche 9 — Notebook (nur R, base R)
# Stichlinge und Zufall: drei Teiche und die neutrale Wolke
# In RStudio: Working Directory = weeks/week-09, dann Zeile fuer Zeile ausfuehren.
# Ausfuehren, Zahlen aendern, Aufgaben beantworten.

# Marine Stichlinge, die heterozygot fuer eine Inversion auf Chromosom XI sind, wurden in drei Suesswasser-Teiche gesetzt. Jedes Jahr wurde gemessen, wie haeufig die Suesswasser-Orientierung der Inversion ist. Alle drei Teiche steigen. Ist das Selektion oder kann das auch Zufall sein?
#
# Die Daten. Fuer jeden Teich (2, 7, 14) und jedes Jahr (0 bis 4) gibt es:
#
# - k: Anzahl Suesswasser-Kopien unter den untersuchten Fischen,
# - n: Anzahl untersuchter Kopien (2 pro Fisch),
# - p = k / n: die Frequenz der Suesswasser-Orientierung.
#
# Jahr 0 ist der Start: nur Heterozygote, also p = 0.5. Teich 7 hat wenige Fische und kein Jahr 4.
#
# Die Abbildungen. Alle Abbildungen haben dieselben Achsen:
#
# - x-Achse: Jahr seit dem Aussetzen (etwa eine Generation pro Jahr),
# - y-Achse: Frequenz der Suesswasser-Orientierung,
# - farbige Linien: die drei Teiche, graue Linien: Simulationen.

# --- Auftrag ---
#
# 1. Zufallszahlen in R ziehen.
# 2. Simulieren, wie weit p ohne Selektion in vier Jahren laufen kann (die neutrale Wolke).
# 3. Suchen, mit welcher Selektion s die Teiche in die Wolke passen.

# ===========================================================================
# 0 · Daten und Funktionen
# ===========================================================================
#
# Einfach ausfuehren.

teiche <- read.csv("data/pond-chrxi.csv")
teiche

teich_farben <- c("2" = "#e67e22", "7" = "#2980b9", "14" = "#1e8449")

# Selektion wie Woche 6 (haploid): aus p wird p_strich
selektion <- function(p, s) p * (1 + s) / (1 + p * s)

# Eine Bahn: jedes Jahr Selektion, dann Zufall (N Kopien ziehen)
simuliere_bahn <- function(s, N, jahre = 4) {
  p <- numeric(jahre + 1)
  p[1] <- 0.5
  for (t in seq_len(jahre)) {
    p_strich <- selektion(p[t], s)
    p[t + 1] <- rbinom(1, N, p_strich) / N
  }
  p
}

zeige_teiche <- function() {
  for (id in c(2, 7, 14)) {
    d <- teiche[teiche$pond == id, ]
    lines(d$year, d$p, lwd = 2.5, col = teich_farben[as.character(id)])
    points(d$year, d$p, pch = 16, col = teich_farben[as.character(id)])
  }
  legend("topleft", paste("Teich", c(2, 7, 14)), col = teich_farben,
         lwd = 2.5, pch = 16, bty = "n")
}

zeige_wolke <- function(s, N, n_bahnen = 100) {
  plot(NA, xlim = c(0, 4), ylim = c(0.2, 1), xlab = "Jahr",
       ylab = "Frequenz Suesswasser-Orientierung",
       main = paste0(n_bahnen, " Bahnen mit s = ", s, ", N = ", N))
  abline(h = 0.5, lty = 3, col = "grey60")
  ende <- numeric(n_bahnen)
  for (i in seq_len(n_bahnen)) {
    p <- simuliere_bahn(s, N)
    lines(0:4, p, col = adjustcolor("grey40", 0.3))
    ende[i] <- p[5]
  }
  zeige_teiche()
  bereich <- round(quantile(ende, c(0.05, 0.95)), 2)
  mtext(paste0("90 % der Bahnen enden in Jahr 4 zwischen ",
               bereich[1], " und ", bereich[2]),
        side = 3, line = 0.2, cex = 0.85)
}

# ===========================================================================
# 1 · Die Daten
# ===========================================================================

plot(NA, xlim = c(0, 4), ylim = c(0.2, 1), xlab = "Jahr",
     ylab = "Frequenz Suesswasser-Orientierung", main = "Drei Teiche, Chr XI")
abline(h = 0.5, lty = 3, col = "grey60")
zeige_teiche()

# Alle steigen, aber jeder anders. Schauen Sie in die Tabelle oben: Wie viele Kopien (n) wurden in Teich 7 untersucht?

# ===========================================================================
# 2 · Zufallszahlen
# ===========================================================================
#
# rbinom(anzahl, size, prob) wuerfelt: Von size Kopien ist jede mit Wahrscheinlichkeit prob eine Suesswasser-Kopie. Wie viele sind es? Das Ganze anzahl-mal.

rbinom(10, size = 250, prob = 0.5)

# --- Aufgabe A ---
#
# 1. Fuehren Sie den Block zweimal aus. Bekommen Sie dieselben Zahlen?
# 2. Schreiben Sie set.seed(1) in die Zeile davor und fuehren Sie den Block zweimal aus. Was aendert sich?
# 3. Teilen Sie die Zahlen durch 250: So stark schwankt p in einer Generation, wenn p = 0.5 und N = 250.

# ===========================================================================
# 3 · Eine Bahn
# ===========================================================================
#
# simuliere_bahn(s, N) rechnet vier Jahre: jedes Jahr erst Selektion (s), dann Zufall (N Kopien ziehen). Das Ergebnis sind fuenf Frequenzen, Jahr 0 bis 4.

simuliere_bahn(s = 0, N = 250)

# --- Aufgabe B ---
#
# 1. Fuehren Sie den Block mehrmals aus. Wie verschieden sind die Bahnen, obwohl s = 0?
# 2. Setzen Sie N = 25. Was aendert sich?

# ===========================================================================
# 4 · Die neutrale Wolke
# ===========================================================================
#
# Eine Bahn sagt wenig. Wir simulieren 100 Bahnen ohne Selektion und legen die Teiche darueber. Ueber der Abbildung steht, wo 90 % der Bahnen in Jahr 4 enden.

set.seed(9)
zeige_wolke(s = 0, N = 250)

# --- Aufgabe C ---
#
# 1. Liegen die Teiche in der grauen Wolke oder darueber?
# 2. Wir kennen N nicht genau. Probieren Sie N = 100 und N = 1000. Wann wird die Wolke breiter, wann schmaler?
# 3. Reicht Zufall allein, um die Teiche zu erklaeren?

# ===========================================================================
# 5 · Welches s passt?
# ===========================================================================
#
# Jetzt mit Selektion. Probieren Sie s = 0.05, 0.1, 0.2 und 0.3 (lassen Sie N = 250).

set.seed(11)
zeige_wolke(s = 0.2, N = 250)   # hier s aendern

# --- Aufgabe D ---
#
# 1. Bei welchem s liegen Teich 2 und 14 gut in der Wolke?
# 2. Teich 7 liegt hoeher. Warum sollte man Teich 7 weniger trauen? (Tipp: n in der Tabelle.)
# 3. Ist das ein Beweis fuer Selektion? Was zeigt das Bild, und was nicht?
#
# Teichdaten: Katie Peichel (Bern) und Dolph Schluter (UBC), unveroeffentlicht, mit freundlicher Genehmigung.
