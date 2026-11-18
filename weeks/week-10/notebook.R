# Woche 10 - Notebook (nur R, base R)
# Werden und Vergehen: neue Mutationen, Verzweigungsprozess, evolutionaere Rettung, zwei Orte
# In RStudio: Working Directory = weeks/week-10, dann Zeile fuer Zeile ausfuehren.
# Quarto: notebook.qmd. Knit ohne Quarto: notebook.Rmd.

# Eine neue Mutation beginnt mit einer Kopie. Auch wenn sie vorteilhaft ist, geht sie oft durch Zufall verloren. Heute simulieren Sie zuerst, wie oft sich eine solche Mutation etabliert. Danach schrumpft eine Population, weil die Umwelt schlecht wird (z. B. ein Antibiotikum). Kann eine resistente Mutation sie retten?
#
# Das Modell. Jedes Individuum hat eine zufaellige Zahl von Nachkommen:
#
# - Mutante (resistent): im Mittel 1 + s Nachkommen,
# - Wildtyp im neuen Stress: im Mittel 1 - r Nachkommen, die Population schrumpft also jede Generation um den Anteil r,
# - Jeder Wildtyp-Nachkomme ist mit Wahrscheinlichkeit U = 0.00001 eine neue Mutante.
#
# Die Abbildungen.
#
# - Teil 1: x-Achse Generation, y-Achse Anzahl Kopien einer Mutation. Blau: ueberlebt, orange: verloren.
# - Teil 2: x-Achse Anzahl simulierter Mutationen, y-Achse Anteil etabliert bisher. Blau: Simulation, orange gestrichelt: 2s.
# - Teil 3: x-Achse Generation, y-Achse Anzahl Individuen auf einer log-Skala (1, 10, 100, ...). Orange: Wildtyp, blau: Mutanten, schwarz: alle zusammen.
# - Teil 4: x-Achse Generation, y-Achse Populationsgroesse (log). Blau: gerettet, grau: ausgestorben.
# - Teil 5: x-Achse Startgroesse N0 (log), y-Achse Anteil geretteter Populationen. Blaue Punkte: Simulation, orange Linie: Formel.

# Auftrag
# 1. Verfolgen Sie einzelne neue Mutationen. Bauen Sie Schritt fuer Schritt einen Verzweigungsprozess und sehen Sie, wie sich der Anteil 2s naehert.
# 2. Lesen und starten Sie ein kleines Programm, das eine schrumpfende Population simuliert.
# 3. Schaetzen Sie mit vielen Laeufen, wie oft sie gerettet wird, vergleichen Sie mit der Formel und sagen Sie voraus, wie das von N_0 und r abhaengt.
# 4. Bonus: Hilft mehr Migration aus einer Zuflucht immer? Erst raten, dann simulieren.

# ===========================================================================
# 0 · Funktionen
# ===========================================================================
#
# Einfach ausfuehren.

# Eine Mutation ueber die Zeit: jede Kopie hat im Mittel 1 + s Nachkommen
linie <- function(s, generationen = 40) {
  n <- numeric(generationen + 1)
  n[1] <- 1
  for (t in seq_len(generationen)) n[t + 1] <- rpois(1, n[t] * (1 + s))
  n
}

zeige_linien <- function(s, anzahl = 20) {
  plot(NA, xlim = c(0, 40), ylim = c(0, 25), xlab = "Generation",
       ylab = "Anzahl Kopien", main = paste("Neue Mutationen mit s =", s))
  verloren <- 0
  for (i in seq_len(anzahl)) {
    n <- linie(s)
    weg <- n[41] == 0
    verloren <- verloren + weg
    lines(0:40, n, col = if (weg) "#e67e22" else "#2166ac", lwd = 1.5)
  }
  mtext(paste(verloren, "von", anzahl, "verloren"), side = 3, line = 0.2)
}

# Anteil etabliert nach 1, 2, 3, ... Laeufen, dazu die Faustregel 2s
zeige_anteil <- function(ergebnisse, s) {
  laeufe <- seq_along(ergebnisse)
  plot(laeufe, cumsum(ergebnisse) / laeufe, type = "l", lwd = 2, col = "#2166ac",
       ylim = c(0, min(1, 4 * s)), xlab = "Anzahl simulierter Mutationen",
       ylab = "Anteil etabliert, bisher", main = paste("s =", s))
  abline(h = 2 * s, lty = 2, lwd = 2, col = "#d95f02")
  legend("topright", c("Simulation", "Faustregel 2s"), col = c("#2166ac", "#d95f02"),
         lty = c(1, 2), lwd = 2, bty = "n")
}

# Eine schrumpfende Population: Wildtyp (1 - r), Mutanten (1 + s)
rettung_lauf <- function(N0, r, s, U = 1e-5, generationen = 120) {
  wt <- N0; mut <- 0
  N <- numeric(generationen + 1); N[1] <- N0
  for (t in seq_len(generationen)) {
    neu <- rbinom(1, wt, U)
    wt <- rpois(1, wt * (1 - r))
    mut <- min(rpois(1, mut * (1 + s)) + neu, 1e7)
    N[t + 1] <- wt + mut
  }
  N
}

zeige_rettung <- function(N0, r, s, anzahl = 10) {
  plot(NA, xlim = c(0, 120), ylim = c(1, 1e7), log = "y", xlab = "Generation",
       ylab = "Populationsgroesse (log)", yaxt = "n",
       main = paste0("N0 = ", N0, ", r = ", r, ", s = ", s))
  axis(2, at = 10^c(0, 2, 4, 6), labels = c("1", "100", "10 000", "1 Mio."), las = 1)
  gerettet <- 0
  for (i in seq_len(anzahl)) {
    N <- rettung_lauf(N0, r, s)
    ok <- N[121] > 0
    gerettet <- gerettet + ok
    lines(0:120, pmax(N, 1), col = if (ok) "#2166ac" else "grey60", lwd = 1.5)
  }
  mtext(paste(gerettet, "von", anzahl, "gerettet"), side = 3, line = 0.2)
}

# 1 = gerettet (1000 Mutanten), 0 = ausgestorben
rettung <- function(N0, r, s, U = 1e-5, grenze = 1000) {
  wt <- N0; mut <- 0
  repeat {
    neu <- rbinom(1, wt, U)
    wt <- rpois(1, wt * (1 - r))
    mut <- rpois(1, mut * (1 + s)) + neu
    if (mut >= grenze) return(1)
    if (wt + mut == 0) return(0)
  }
}

schaetze_rettung <- function(N0, r, s, wiederholungen = 300) {
  mean(replicate(wiederholungen, rettung(N0, r, s)))
}

# Naeherung (Orr & Unckless 2014)
formel <- function(N0, r, s, U = 1e-5) round(1 - exp(-2 * N0 * U * s / r), 2)
# Simulation (Punkte) und Formel (Linie) fuer viele Startgroessen
vergleiche_rettung <- function(r, s, N0_werte = c(1e3, 3e3, 1e4, 3e4, 1e5, 3e5),
                               wiederholungen = 200, U = 1e-5) {
  sim <- sapply(N0_werte, function(N0) schaetze_rettung(N0, r, s, wiederholungen))
  N0_fein <- 10^seq(log10(min(N0_werte)), log10(max(N0_werte)), length.out = 100)
  plot(N0_fein, 1 - exp(-2 * N0_fein * U * s / r), type = "l", lwd = 2, lty = 2,
       col = "#d95f02", log = "x", ylim = c(0, 1), xlab = "Startgroesse N0 (log)",
       ylab = "Anteil gerettet", main = paste0("r = ", r, ", s = ", s), xaxt = "n")
  axis(1, at = c(1e3, 1e4, 1e5), labels = c("1 000", "10 000", "100 000"))
  points(N0_werte, sim, pch = 16, cex = 1.4, col = "#2166ac")
  legend("topleft", c("Simulation", "Formel"), col = c("#2166ac", "#d95f02"),
         pch = c(16, NA), lty = c(NA, 2), lwd = 2, bty = "n")
  invisible(data.frame(N0 = N0_werte, simulation = sim))
}

# ===========================================================================
# 1 · Eine neue Mutation
# ===========================================================================
#
# 20 neue Mutationen, jede startet mit einer Kopie und hat den Vorteil s = 0.1.

zeige_linien(s = 0.1)   # hier s aendern

# Aufgabe A
# 1. Wie viele der 20 Mutationen gehen verloren? Fuehren Sie den Block mehrmals aus.
# 2. Probieren Sie s = 0 und s = 0.3. Was aendert sich?
# 3. Warum geht eine vorteilhafte Mutation ueberhaupt verloren?

# ===========================================================================
# 2 · Ein Verzweigungsprozess, Schritt fuer Schritt
# ===========================================================================
#
# Jetzt bauen Sie den Verzweigungsprozess aus der Vorlesung selbst, mit dem Spielzeugmodell: Jede Kopie hat entweder keine oder zwei Nachkommen. Keine mit Wahrscheinlichkeit a = (1 - s)/2, sonst zwei. Im Mittel sind das 1 + s.

# Schritt 1: eine Generation. Jede Kopie wirft eine Muenze. rbinom(1, n, 1 - a) zaehlt, wie viele von n Kopien zwei Nachkommen haben (wie in Woche 9). Mal 2 gibt die Kopien der naechsten Generation.

s <- 0.1
a <- (1 - s) / 2          # Chance auf keine Nachkommen
n <- 1                    # eine Kopie
2 * rbinom(1, n, 1 - a)   # Kopien in der naechsten Generation: 0 oder 2

# Schritt 2: Generation fuer Generation. Dieselbe Zeile, solange (while) die Mutation weder verloren (0 Kopien) noch etabliert (100 Kopien) ist. verlauf merkt sich alle Zahlen.

n <- 1                          # eine neue Mutation
verlauf <- n
while (n > 0 && n < 100) {      # solange nicht verloren und nicht etabliert
  n <- 2 * rbinom(1, n, 1 - a)
  verlauf <- c(verlauf, n)
}
verlauf
length(verlauf) - 1             # wie viele Generationen?

# Schritt 3: als Funktion, viele Male. Wir packen Schritt 2 in eine Funktion. Sie gibt 1 zurueck, wenn die Mutation sich etabliert, sonst 0. replicate startet viele neue Mutationen.

eine_linie <- function(s) {
  a <- (1 - s) / 2
  n <- 1
  while (n > 0 && n < 100) {
    n <- 2 * rbinom(1, n, 1 - a)
  }
  as.numeric(n >= 100)   # 1 = etabliert, 0 = verloren
}

s <- 0.1                                  # hier s aendern
ergebnisse <- replicate(3000, eine_linie(s))
mean(ergebnisse)   # Anteil etabliert
2 * s              # Faustregel 2s

# Schritt 4: Wie naehert sich der Anteil 2s? zeige_anteil zeichnet den Anteil etablierter Mutationen nach 1, 2, 3, ... Laeufen. Die gestrichelte Linie ist 2s.

zeige_anteil(ergebnisse, s)

# Aufgabe B
# 1. Fuehren Sie Schritt 1 zehnmal aus. Wie oft gibt es keine Nachkommen? Passt das zu a = 0.45?
# 2. Fuehren Sie Schritt 2 mehrmals aus. Wie oft schafft es die Mutation? Wie viele Generationen dauert es, wenn sie verloren geht, und wenn sie es schafft?
# 3. Aendern Sie in Schritt 3 nur s und fuellen Sie die Tabelle aus:
#
# | s | Simulation | Faustregel 2s |
# |---|---|---|
# | 0.02 |  |  |
# | 0.05 |  |  |
# | 0.1 |  |  |
# | 0.2 |  |  |
# 4. Schauen Sie sich Schritt 4 fuer s = 0.02 und s = 0.2 an. Wann passt 2s gut, wann liegt die Simulation darunter? Nach wie vielen Laeufen beruhigt sich die Kurve?

# ===========================================================================
# 3 · Ein Programm fuer Rettung
# ===========================================================================
#
# Jetzt schreiben wir das Modell selbst aus. Das ganze Programm hat drei Teile:
#
# 1. Zustand: Wie viele Wildtypen (wt) und wie viele Mutanten (mut) gibt es?
# 2. Eine Generation: neue Mutanten ziehen, dann Nachkommen ziehen.
# 3. Schleife: die Generation viele Male wiederholen.
#
# Neu ist rpois(1, mittel): eine zufaellige ganze Zahl mit Mittelwert mittel. Wir brauchen sie fuer die Zahl der Nachkommen einer ganzen Gruppe. Bei 1000 Wildtypen und r = 0.1 ist rpois(1, 900) etwa 900, aber nicht genau. rbinom kennen Sie aus Woche 9: Von wt Nachkommen ist jeder mit Wahrscheinlichkeit U ein Mutant.

N0 <- 30000   # Startgroesse
r  <- 0.1     # Rueckgang des Wildtyps pro Generation
s  <- 0.1     # Vorteil der Mutante
U  <- 1e-5    # Mutationsrate
generationen <- 150

# 1. Zustand: ein Platz pro Generation
wt  <- numeric(generationen + 1)
mut <- numeric(generationen + 1)
wt[1]  <- N0
mut[1] <- 0

# 2. und 3.: eine Generation, viele Male
for (t in 1:generationen) {
  neu        <- rbinom(1, wt[t], U)                # neue Mutanten unter den Wildtypen
  wt[t + 1]  <- rpois(1, wt[t] * (1 - r))          # Wildtyp: im Mittel 1 - r Nachkommen
  mut[t + 1] <- rpois(1, mut[t] * (1 + s)) + neu   # Mutanten: im Mittel 1 + s Nachkommen
}

plot(0:generationen, pmax(wt + mut, 1), type = "l", lwd = 3, log = "y",
     xlab = "Generation", ylab = "Individuen (log)", ylim = c(1, 1e7))
lines(0:generationen, pmax(wt, 1),  col = "#e67e22", lwd = 2)
lines(0:generationen, pmax(mut, 1), col = "#2166ac", lwd = 2)
legend("topright", c("alle", "Wildtyp", "Mutanten"), col = c("black", "#e67e22", "#2166ac"),
       lwd = 2, bty = "n")

which(mut > 0)[1] - 1   # in welcher Generation gibt es zum ersten Mal Mutanten?

# Aufgabe C
# 1. Fuehren Sie den Block mehrmals aus. Wann entsteht die erste Mutante? Wird die Population jedes Mal gerettet?
# 2. Suchen Sie in einer geretteten Population die U-Kurve. Wer schrumpft, wer waechst?
# 3. Setzen Sie U <- 0. Was passiert, und warum?
# 4. Manchmal entsteht eine Mutante und verschwindet wieder. Woran sieht man das in der Abbildung?

# --- Von einem Lauf zur Wahrscheinlichkeit ---
#
# Ein Lauf sagt nur: gerettet oder nicht. Um eine Wahrscheinlichkeit zu schaetzen, packen wir das Programm in eine Funktion und lassen sie viele Male laufen. Die Schleife laeuft jetzt so lange, bis die Population ausgestorben ist oder 1000 Mutanten hat (while: "solange").

ein_lauf <- function(N0, r, s, U = 1e-5) {
  wt <- N0
  mut <- 0
  while (wt + mut > 0 && mut < 1000) {   # solange nicht ausgestorben und nicht gerettet
    neu <- rbinom(1, wt, U)
    wt  <- rpois(1, wt * (1 - r))
    mut <- rpois(1, mut * (1 + s)) + neu
  }
  as.numeric(mut >= 1000)   # 1 = gerettet, 0 = ausgestorben
}

ergebnisse <- replicate(200, ein_lauf(N0 = 30000, r = 0.1, s = 0.1))
sum(ergebnisse)    # wie viele von 200 gerettet?
mean(ergebnisse)   # Anteil: Schaetzung der Wahrscheinlichkeit

# Das ist das ganze Rezept jeder solchen Simulation: Zustand, eine Generation, Schleife, Abbruch, viele Wiederholungen.

# ===========================================================================
# 4 · Viele Laeufe ansehen
# ===========================================================================
#
# Eine Population mit N_0 = 30\,000 Individuen geraet in Stress und schrumpft jede Generation um r = 10\,\%. Resistente Mutanten haben den Vorteil s = 0.1. Die Abbildung zeigt 10 Wiederholungen.

zeige_rettung(N0 = 30000, r = 0.1, s = 0.1)   # hier N0 oder r aendern

# Aufgabe D
# 1. Beschreiben Sie eine blaue Kurve: Was passiert zuerst, was danach?
# 2. Probieren Sie N_0 = 3000 und N_0 = 300\,000. Was aendert sich?
# 3. Probieren Sie r = 0.3 (mit N_0 = 30\,000). Was aendert sich?

# ===========================================================================
# 5 · Simulation und Formel
# ===========================================================================
#
# Jetzt vergleichen wir die Simulation mit der Formel aus der Vorlesung, P ~ 1 - exp(-2 N0 U s / r). vergleiche_rettung simuliert fuer sechs Startgroessen je 200 Populationen (Punkte) und zeichnet die Formel dazu (Linie). Das dauert ein paar Sekunden.

set.seed(1)
vergleiche_rettung(r = 0.1, s = 0.1)   # hier r oder s aendern

# Aufgabe E
# 1. Wo trifft die Formel die Simulation gut, wo weniger?
# 2. Erst raten, dann rechnen: Was passiert mit der Kurve, wenn die Population doppelt so schnell schrumpft (r = 0.2)? Notieren Sie Ihre Vermutung, dann lassen Sie den Block laufen.
# 3. Und wenn die Mutante nur halb so viel Vorteil hat (s = 0.05, r = 0.1)? Vergleichen Sie mit Ihrer Antwort auf 2.
# 4. Ab welchem N_0 wird etwa die Haelfte gerettet? Lesen Sie es ab.
# 5. Was bedeutet das fuer Bakterien unter Antibiotika (Milliarden Zellen) und fuer eine bedrohte Art mit wenigen hundert Tieren?

# ===========================================================================
# 6 · Bonus: Ueberraschung mit zwei Orten
# ===========================================================================
#
# Tomasini & Peischl (2020): Zwei Orte tauschen Individuen aus. Ort 1 wird sofort schlecht, Ort 2 ist zuerst eine Zuflucht und wird erst nach \theta = 100 Generationen schlecht.
#
# - Wildtyp im schlechten Ort: im Mittel 1 - r Nachkommen. In der Zuflucht bleibt er bei K = 5000.
# - Mutante im schlechten Ort: 1 + z. In der Zuflucht hat sie Kosten: 1 - s.
# - Jede Generation wechselt ein Anteil m/2 jedes Ortes zum anderen Ort.
# - Gerettet, sobald es irgendwo 500 Mutanten gibt.
#
# Erst raten: Hilft mehr Migration aus einer Zuflucht immer? Notieren Sie Ihre Vermutung, bevor Sie die Bloecke laufen lassen.
#
# Das Programm ist dasselbe Rezept wie in Teil 3, nur sind wt und mut jetzt Vektoren mit zwei Eintraegen (Ort 1, Ort 2), und nach den Nachkommen kommt ein dritter Schritt: Migration.

zwei_orte <- function(m, s, z, r, K = 5000, theta = 100, U = 2e-5, grenze = 500) {
  wt  <- c(K, K)   # Wildtyp in Ort 1 und Ort 2
  mut <- c(0, 0)   # Mutanten in Ort 1 und Ort 2
  for (t in 1:1000) {
    schlecht <- c(TRUE, t > theta)
    wt  <- rpois(2, wt * ifelse(schlecht, 1 - r, 1))
    if (!schlecht[2]) wt[2] <- K                  # Zuflucht bleibt voll
    neu <- rbinom(2, wt, U)                       # neue Mutanten
    mut <- rpois(2, mut * ifelse(schlecht, 1 + z, 1 - s)) + neu
    weg_wt  <- rbinom(2, wt,  m / 2)              # Migration
    weg_mut <- rbinom(2, mut, m / 2)
    wt  <- wt  - weg_wt  + rev(weg_wt)
    mut <- mut - weg_mut + rev(weg_mut)
    if (sum(mut) >= grenze) return(1)             # gerettet
    if (sum(wt) + sum(mut) == 0) return(0)        # ausgestorben
  }
  0
}

zeige_migration <- function(s, z, r, wiederholungen = 200) {
  m_werte <- c(0, 0.01, 0.05, 0.1, 0.2, 0.4, 0.7, 1)
  p <- sapply(m_werte, function(m) mean(replicate(wiederholungen, zwei_orte(m, s, z, r))))
  plot(seq_along(m_werte), p, type = "b", pch = 16, lwd = 2, col = "#2166ac",
       ylim = c(0, 1), xaxt = "n", xlab = "Migrationsrate m", ylab = "Anteil gerettet",
       main = paste0("s = ", s, ", z = ", z, ", r = ", r))
  axis(1, at = seq_along(m_werte), labels = m_werte)
  invisible(data.frame(m = m_werte, gerettet = p))
}

# Jeder Punkt: 200 Populationen bei einer Migrationsrate.

set.seed(1)
zeige_migration(s = 0.02, z = 0.1, r = 0.1)   # billige Mutante

set.seed(1)
zeige_migration(s = 0.5, z = 0.2, r = 0.2)    # teure Mutante: bitte s aendern

# Aufgabe F (Bonus)
# 1. Billige Mutante (s = 0.02): Hilft Migration? Wie viel mehr Populationen werden gerettet als ohne Migration (m = 0)?
# 2. Teure Mutante (s = 0.5): Bei welcher Migrationsrate ist Rettung am wahrscheinlichsten? Was passiert bei sehr viel Migration?
# 3. Erklaeren Sie den Unterschied mit dem Wort gene swamping: Wo landen die Mutanten bei viel Migration, und was passiert dort mit ihnen?
# 4. Tomasini & Peischl (2020) leiten her: Genfluss hilft, wenn s/z < r theta. Pruefen Sie die Bedingung, fuer beide Faelle (\theta = 100). Was sagt sie, was sagt sie nicht?

