# Woche 9 — Notebook (nur R, base R)
# Zufall und Notwendigkeit: drei Teiche und die neutrale Wolke
#
# "Alles, was im Universum existiert, ist die Frucht von Zufall und Notwendigkeit." (Demokrit)
# In RStudio: Working Directory = weeks/week-09, dann Zeile fuer Zeile ausfuehren.
# Ausfuehren, Zahlen aendern, Aufgaben beantworten.

# Marine Stichlinge, die heterozygot fuer eine Inversion auf Chromosom XI sind, wurden in drei Suesswasser-Teiche gesetzt. Jedes Jahr wurde gemessen, wie haeufig die Suesswasser-Orientierung der Inversion ist. Alle drei Teiche steigen. Ist das Selektion oder kann das auch Zufall sein?
#
# Um das zu beantworten, bauen wir Schritt fuer Schritt ein Modell mit Zufall: zuerst eine Muenze, dann eine Generation, dann vier Jahre, dann hundert Wiederholungen.
#
# Die Daten. Fuer jeden Teich (2, 7, 14) und jedes Jahr (0 bis 4) gibt es:
#
# - k: Anzahl Suesswasser-Kopien unter den untersuchten Fischen,
# - n: Anzahl untersuchter Kopien (2 pro Fisch),
# - p = k / n: die Frequenz der Suesswasser-Orientierung.
#
# Jahr 0 ist der Start: nur Heterozygote, also p = 0.5. Teich 7 hat wenige Fische und kein Jahr 4.
#
# Die Abbildungen. Die Abbildungen mit den Teichen haben alle dieselben Achsen:
#
# - x-Achse: Jahr seit dem Aussetzen (etwa eine Generation pro Jahr),
# - y-Achse: Frequenz der Suesswasser-Orientierung,
# - farbige Linien: die drei Teiche, graue Linien: Simulationen.

# --- Auftrag ---
#
# 1. Lernen, wie man in R Zufallszahlen zieht, und wie stark sie schwanken.
# 2. Daraus eine Population bauen, deren Frequenz p sich zufaellig aendert (Drift).
# 3. Simulieren, wie weit p ohne Selektion in vier Jahren laufen kann (die neutrale Wolke).
# 4. Suchen, mit welcher Selektion s die Teiche in die Wolke passen.

# ===========================================================================
# 0 · Daten und Funktionen
# ===========================================================================
#
# Einfach ausfuehren.

teiche <- read.csv("data/pond-chrxi.csv")
teiche

teich_farben <- c("2" = "#e67e22", "7" = "#2980b9", "14" = "#1e8449")

zeige_teiche <- function() {
  for (id in c(2, 7, 14)) {
    d <- teiche[teiche$pond == id, ]
    lines(d$year, d$p, lwd = 2.5, col = teich_farben[as.character(id)])
    points(d$year, d$p, pch = 16, col = teich_farben[as.character(id)])
  }
  legend("topleft", paste("Teich", c(2, 7, 14)), col = teich_farben,
         lwd = 2.5, pch = 16, bty = "n")
}

# braucht simuliere_bahn() aus Teil 5
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

# Alle steigen, aber jeder anders. Schauen Sie in die Tabelle oben: Wie viele Kopien (n) wurden in Teich 7 untersucht, wie viele in Teich 2?

# ===========================================================================
# 2 · Zufall in R
# ===========================================================================
#
# Woher kommt der Zufall in einer Population? Welcher Fisch ueberlebt, wie viele Junge er hat und welche seiner zwei Kopien er weitergibt (Mendel!), ist zum Teil Glueck. Im Modell ersetzen wir dieses Glueck durch Zufallszahlen. Wir beginnen mit dem einfachsten Zufall: einer Muenze.

# --- Eine Muenze ---
#
# sample(x, size) zieht zufaellig size Elemente aus x.

sample(c("Kopf", "Zahl"), size = 1)

# Fuehren Sie den Block mehrmals aus. Jedes Mal kann etwas anderes herauskommen.

# --- Viele Muenzen ---
#
# Fuer mehrere Wuerfe braucht es replace = TRUE (mit Zuruecklegen: «Kopf» darf mehrmals vorkommen).

wuerfe <- sample(c("Kopf", "Zahl"), size = 10, replace = TRUE)
wuerfe
sum(wuerfe == "Kopf")   # wie oft Kopf?

# wuerfe == "Kopf" gibt fuer jeden Wurf TRUE oder FALSE. sum() zaehlt die TRUE.

# --- Wiederholbarer Zufall: set.seed ---
#
# Ein Computer kann nicht wirklich wuerfeln. R berechnet Zahlen, die zufaellig aussehen (Pseudo-Zufallszahlen). Der Startwert dieser Rechnung heisst Seed. Mit gleichem Seed kommen die gleichen Zahlen.

set.seed(1)
sample(c("Kopf", "Zahl"), size = 10, replace = TRUE)
set.seed(1)
sample(c("Kopf", "Zahl"), size = 10, replace = TRUE)

# Das ist nuetzlich, damit andere (und Sie selbst naechste Woche) genau dasselbe Ergebnis bekommen.

# --- Von Muenzen zu Genkopien ---
#
# Jetzt eine Generation im Teich: N = 250 Genkopien. Jede ist mit Wahrscheinlichkeit p = 0.5 eine Suesswasser-Kopie (1), sonst eine Meer-Kopie (0). Das ist dasselbe wie 250 Muenzwuerfe.

kopien <- sample(c(1, 0), size = 250, replace = TRUE, prob = c(0.5, 0.5))
head(kopien, 20)   # die ersten 20 Kopien
sum(kopien)        # Anzahl Suesswasser-Kopien
mean(kopien)       # Frequenz p in der neuen Generation

# Mit prob legen wir fest, wie wahrscheinlich jedes Element ist. mean() einer 0/1-Folge ist der Anteil der Einsen, also p.

# --- Die Abkuerzung: rbinom ---
#
# Uns interessiert nur die Anzahl der Suesswasser-Kopien, nicht welche Kopie welche ist. Diese Anzahl wuerfelt rbinom direkt:

rbinom(1, size = 250, prob = 0.5)

# rbinom(anzahl, size, prob): Von size Kopien ist jede mit Wahrscheinlichkeit prob eine Suesswasser-Kopie. Wie viele sind es? Das Ganze anzahl-mal. Hier zehnmal:

rbinom(10, size = 250, prob = 0.5)

# --- Aufgabe A ---
#
# 1. Werfen Sie 100 Muenzen mit sample und zaehlen Sie «Kopf». Wie nahe ist das an 50?
# 2. Fuehren Sie rbinom(10, size = 250, prob = 0.5) zweimal aus. Bekommen Sie dieselben Zahlen? Und mit set.seed(1) in der Zeile davor?
# 3. Aendern Sie prob auf 0.8. Wo liegen die Zahlen jetzt ungefaehr? Warum?

# ===========================================================================
# 3 · Wie stark schwankt p in einer Generation?
# ===========================================================================
#
# Zehn Zahlen sind wenig. Wir ziehen 1000 neue Generationen, alle aus derselben Elterngeneration mit p = 0.5, und teilen durch N, um Frequenzen zu bekommen.

N <- 250   # hier aendern
p_neu <- rbinom(1000, size = N, prob = 0.5) / N
hist(p_neu, breaks = seq(0, 1, by = 0.02), xlim = c(0, 1), col = "grey80",
     main = paste("1000 neue Generationen, N =", N), xlab = "Frequenz p in der neuen Generation")
abline(v = 0.5, col = "red", lwd = 2)
mean(p_neu)   # Mittelwert
sd(p_neu)     # Standardabweichung: wie stark p schwankt

# Im Mittel bleibt p bei 0.5 (rote Linie): Zufall hat keine Richtung. Aber einzelne Generationen weichen ab. Wie stark, misst die Standardabweichung sd. Die Theorie sagt:
#
# 
# \text{sd} = \sqrt{\frac{p\,(1-p)}{N}}
# 

sqrt(0.5 * (1 - 0.5) / N)

# --- Aufgabe B ---
#
# Fuellen Sie die Tabelle aus (oben N aendern):
#
# | N | sd(p_neu) | Formel |
# | 25 |  |  |
# | 250 |  |  |
# | 2500 |  |  |
#
# Wie haengt die Schwankung von N ab? Um wie viel muss N wachsen, damit die Schwankung halb so gross wird?

# ===========================================================================
# 4 · Viele Generationen: Drift
# ===========================================================================
#
# Jetzt haengen wir Generationen aneinander. Die neue Generation wird aus der vorherigen gezogen, nicht immer aus p = 0.5. Dafuer brauchen wir eine Schleife (for). Lesen Sie den Code Zeile fuer Zeile:

N <- 250             # Anzahl Genkopien
generationen <- 4    # hier aendern
p <- numeric(generationen + 1)   # leerer Vektor fuer alle Frequenzen
p[1] <- 0.5                      # Start
for (t in 1:generationen) {
  p[t + 1] <- rbinom(1, size = N, prob = p[t]) / N   # neue aus alter Generation
}
p
plot(0:generationen, p, type = "b", pch = 16, ylim = c(0, 1),
     xlab = "Generation", ylab = "Frequenz p", main = paste("Eine Bahn, N =", N))
abline(h = 0.5, lty = 3, col = "grey60")

# Eine solche Folge von Frequenzen nennen wir eine Bahn. Die zufaellige Aenderung von p heisst genetische Drift.

# --- Aufgabe C ---
#
# 1. Fuehren Sie den Block mehrmals aus. Wie verschieden sind die Bahnen, obwohl es keine Selektion gibt?
# 2. Setzen Sie N <- 25. Was aendert sich?
# 3. Setzen Sie N <- 25 und generationen <- 100. Was passiert am Ende fast immer? Warum kann p von dort nicht mehr weg?

# ===========================================================================
# 5 · Selektion und Zufall zusammen
# ===========================================================================
#
# Jetzt kommt die Selektion aus Woche 6 dazu. Jede Generation passiert zwei Dinge:
#
# 1. Selektion macht aus p den erwarteten Anteil p' (ohne Zufall, wie bisher),
# 2. Zufall: N Kopien werden mit Wahrscheinlichkeit p' gezogen.
#
# Fuehren Sie diesen Block aus. Die Wolken in Teil 6 und 7 brauchen ihn.

# Selektion wie Woche 6 (haploid): aus p wird p_strich
selektion <- function(p, s) p * (1 + s) / (1 + p * s)

# Eine Bahn ueber vier Jahre: jedes Jahr erst Selektion, dann Zufall
simuliere_bahn <- function(s, N, jahre = 4) {
  p <- numeric(jahre + 1)
  p[1] <- 0.5
  for (t in seq_len(jahre)) {
    p_strich <- selektion(p[t], s)
    p[t + 1] <- rbinom(1, N, p_strich) / N
  }
  p
}

# Vergleich: einmal ohne Zufall (nur selektion), dreimal mit Zufall.

p_ohne <- 0.5
for (t in 1:4) p_ohne[t + 1] <- selektion(p_ohne[t], s = 0.2)
round(p_ohne, 3)
simuliere_bahn(s = 0.2, N = 250)
simuliere_bahn(s = 0.2, N = 250)
simuliere_bahn(s = 0.2, N = 250)

# --- Aufgabe D ---
#
# 1. Ohne Zufall: Wo endet p nach vier Jahren mit s = 0.2?
# 2. Mit Zufall: Enden die Bahnen immer hoeher als 0.5? Immer genau dort wie ohne Zufall?
# 3. Probieren Sie s = 0. Was ist dann p_ohne?

# ===========================================================================
# 6 · Die neutrale Wolke
# ===========================================================================
#
# Eine Bahn sagt wenig. Wir simulieren 100 Bahnen ohne Selektion (s = 0) und legen die Teiche darueber. Ueber der Abbildung steht, wo 90 % der Bahnen in Jahr 4 enden.

set.seed(9)
zeige_wolke(s = 0, N = 250)

# N = 250 ist eine Schaetzung: etwa so viele Genkopien tragen in einem Teich zur naechsten Generation bei.

# --- Aufgabe E ---
#
# 1. Liegen die Teiche in der grauen Wolke oder darueber?
# 2. Wir kennen N nicht genau. Probieren Sie N = 100 und N = 1000. Wann wird die Wolke breiter, wann schmaler? Passt das zu Aufgabe B?
# 3. Reicht Zufall allein, um die Teiche zu erklaeren?

# ===========================================================================
# 7 · Welches s passt?
# ===========================================================================
#
# Jetzt mit Selektion. Probieren Sie s = 0.05, 0.1, 0.2 und 0.3 (lassen Sie N = 250).

set.seed(11)
zeige_wolke(s = 0.2, N = 250)   # hier s aendern

# --- Aufgabe F ---
#
# 1. Bei welchem s liegen Teich 2 und 14 gut in der Wolke?
# 2. Liegt Teich 7 auch in der Wolke?

# ===========================================================================
# 8 · Ein zweiter Zufall: die Stichprobe
# ===========================================================================
#
# Die Frequenzen der Teiche sind gemessen, nicht die wahren Werte. Im Teich leben viele Fische, untersucht wird nur ein Teil. Auch das ist eine Ziehung. Angenommen, die wahre Frequenz ist 0.6:

n <- 20   # untersuchte Kopien; hier aendern
gemessen <- rbinom(1000, size = n, prob = 0.6) / n
hist(gemessen, breaks = seq(0, 1, by = 0.025), xlim = c(0, 1), col = "grey80",
     main = paste("1000 Stichproben mit je", n, "Kopien, wahre Frequenz 0.6"),
     xlab = "gemessene Frequenz")
abline(v = 0.6, col = "red", lwd = 2)
round(quantile(gemessen, c(0.05, 0.95)), 2)   # 90 % der Messungen liegen hier

# --- Aufgabe G ---
#
# 1. Teich 7 hat pro Jahr nur 10–43 untersuchte Kopien, Teich 2 meist ueber 80. Probieren Sie n <- 20 und n <- 200. Wie genau ist eine Messung?
# 2. Warum sollte man Teich 7 weniger trauen als Teich 2?
# 3. Ist das Bild aus Teil 7 ein Beweis fuer Selektion? Was zeigt es, und was nicht?
#
# Teichdaten: Katie Peichel (Bern) und Dolph Schluter (UBC), unveroeffentlicht, mit freundlicher Genehmigung.
