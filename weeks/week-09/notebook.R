# Woche 9 — Notebook (nur R)
# Zufall und Notwendigkeit
# In RStudio: Working Directory = weeks/week-09, dann Zeile fuer Zeile ausfuehren.
# Quarto: notebook.qmd. Knit ohne Quarto: notebook.Rmd.

# In der Vorlesung wandert die Frequenz in den Teichen. Zwei Dinge koennen
# eine gemessene Frequenz verschieben: die Population ist endlich, und die
# Stichprobe ist nur ein Teil davon.
#
# Dieses Notebook rechnet die Teiche nicht noch einmal. Sie kommen nur am Ende
# von Teil A kurz zurueck.
# 1. Wie haengt die Wanderung von der Populationsgroesse N ab, wenn das Allel neutral ist?
# 2. Was sieht man von den Kehlfarben der Echsen aus Woche 4, wenn der Fang Zufall ist?

# --- Auftrag ---
# 1. Eine Binomialverteilung anschauen und set.seed ausprobieren.
# 2. Ein neutrales Allel viele Generationen verfolgen, grosse und kleine Population.
#    Dann mit den Teichen vergleichen.
# 3. Drei Stichproben von Echsen ziehen. Der Fangbias am Schluss ist ein Bonus.

# ===========================================================================
# 0 · Zufallszahlen
# ===========================================================================
#
# rbinom(anzahl, size, prob) zieht anzahl Mal, wie viele von size Versuchen
# erfolgreich waren. Jeder Versuch klappt mit Wahrscheinlichkeit prob.
# set.seed legt den Startwert fest.

set.seed(2026)

x <- rbinom(1000, size = 20, prob = 0.5)
hist(x, breaks = 0:21 - 0.5,
     main = "1000 Ziehungen", xlab = "X ~ Binomial(20, 0.5)", ylab = "Anzahl")

# F1
# 1. Denselben Block ohne set.seed zweimal laufen lassen. Aendert sich das Histogramm?
# 2. prob = 0.1. Wie veraendert sich die Verteilung? Warum?

# ===========================================================================
# A · Populationsgroesse
# ===========================================================================
#
# Neutrales Allel, Frequenz p, fixe Populationsgroesse N, haploid.
# Jede Generation wird aus der vorherigen gezogen. Derselbe Schritt wie in
# der Vorlesung, hier ohne Selektion.

WF_step <- function(p, N) {
  N_p <- rbinom(1, N, p)   # wie viele der N Individuen tragen das Allel?
  N_p / N
}

# --- Eine Generation ---
#
# F2. Eine Generation mit p = 0.5 und N = 1000.
# Erwarten Sie Abnahme, Zunahme, oder bleibt p nahe 0.5?
# Chunk mehrmals laufen lassen.

WF_step(p = 0.5, N = 1000)

# --- Viele Generationen ---

simulateWF <- function(p_0, N, generationen = 250) {
  p <- numeric(generationen + 1)
  p[1] <- p_0
  for (t in seq_len(generationen)) {
    p[t + 1] <- WF_step(p[t], N)
  }
  data.frame(generation = 0:generationen, p = p)
}

# Grosse Population. F3: p_0 aendern.

p_0 <- 0.5   # bitte aendern

large_pop <- simulateWF(p_0, N = 1000)

plot(large_pop$generation, large_pop$p, type = "l", lwd = 2, col = "plum4",
     xlab = "Generationen", ylab = "Allelfrequenz", ylim = c(0, 1),
     main = "N = 1000")
abline(h = p_0, lwd = 1, lty = 2)

# Kleine Population.
# F4. Was erwarten Sie fuer N = 100, bevor Sie den Block laufen lassen?

p_0 <- 0.5   # bitte aendern

small_pop <- simulateWF(p_0, N = 100)

plot(small_pop$generation, small_pop$p, type = "l", lwd = 2, col = "plum4",
     xlab = "Generationen", ylab = "Allelfrequenz", ylim = c(0, 1),
     main = "N = 100")
abline(h = p_0, lwd = 1, lty = 2)

# F5
# - Block ein paar Mal laufen lassen. Was beobachten Sie?
# - Stieg oder fiel p hier, weil das Allel einen Vorteil hatte?
# - Was heisst das fuer die genetische Vielfalt in einer kleinen Population?

# ---------------------------------------------------------------------------
# Zurueck zu den Teichen
# ---------------------------------------------------------------------------
# Die Teiche starten bei p = 0.5 und liegen nach drei bis vier Jahren bei etwa
# 0.63 (Teich 2 und 14) und 0.84 (Teich 7). Kann ein neutrales Allel das allein
# durch Zufall schaffen? 100 Laeufe, je 4 Generationen, nur die Frequenz am Ende.

N <- 250   # bitte aendern

set.seed(2026)
p_ende <- numeric(100)
for (i in 1:100) {
  bahn <- simulateWF(p_0 = 0.5, N = N, generationen = 4)
  p_ende[i] <- bahn$p[5]
}

hist(p_ende, breaks = seq(0, 1, by = 0.025), xlim = c(0.2, 1),
     main = paste("100 neutrale Bahnen, N =", N),
     xlab = "Allelfrequenz nach 4 Generationen", ylab = "Anzahl")
abline(v = c(0.637, 0.625, 0.837), lwd = 2,
       col = c("#e67e22", "#1e8449", "#2980b9"))   # Teich 2, 14, 7

sum(p_ende >= 0.62)   # wie viele Bahnen kommen so hoch wie die Teiche?

# F6
# - Wie viele der 100 neutralen Bahnen kommen so hoch wie die Teiche? Und wie viele so hoch wie Teich 7?
# - N auf 50 und dann auf 25 setzen. Wie klein muesste die Population sein, damit Zufall allein reicht?
# - In jedem Teich leben Hunderte Stichlinge. Was muss also zum Zufall dazukommen?

# ===========================================================================
# B · Stichprobengroesse
# ===========================================================================
#
# Woche 4: Kehlfarben von Uta stansburiana. Hier sind die Anteile gegeben.
# Zufaellig ist nur, wen Sie fangen. Drei Stichproben mit je n Echsen.
#
# rmultinom(n, size, prob): drei Farben auf einmal.
# size = Zahl gefangener Echsen, prob = Anteil jeder Farbe.
# Balken von unten nach oben: orange, blau, gelb.

# --- Jahr 1 ---

lizard_pop_y1 <- c(0.5, 0.25, 0.25)   # orange, blau, gelb

sample_size <- 20   # bitte aendern

set.seed(2026)
sample1 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_y1)
sample2 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_y1)
sample3 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_y1)

data_y1 <- data.frame(
  Wirklichkeit = lizard_pop_y1,
  Stichprobe_1 = as.numeric(sample1) / sample_size,
  Stichprobe_2 = as.numeric(sample2) / sample_size,
  Stichprobe_3 = as.numeric(sample3) / sample_size
)
data_y1$Mittel <- (data_y1$Stichprobe_1 + data_y1$Stichprobe_2 + data_y1$Stichprobe_3) / 3

barplot(as.matrix(data_y1),
        col = c("#e67e22", "#2980b9", "#f1c40f"),
        ylim = c(0, 1.45),
        legend.text = c("orange", "blau", "gelb"),
        args.legend = list(bty = "n", x = "topright"),
        main = paste("Stichprobengroesse", sample_size, ", Jahr 1"),
        ylab = "Anteil")

# F7
# - Stimmen die Stichproben mit der Population ueberein?
# - sample_size aendern. Was beobachten Sie?

# --- Jahr 2: gelb ist selten ---

lizard_pop_y2 <- c(0.15, 0.8, 0.05)   # orange, blau, gelb

sample_size <- 20   # bitte aendern

set.seed(2026)
sample1 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_y2)
sample2 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_y2)
sample3 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_y2)

data_y2 <- data.frame(
  Wirklichkeit = lizard_pop_y2,
  Stichprobe_1 = as.numeric(sample1) / sample_size,
  Stichprobe_2 = as.numeric(sample2) / sample_size,
  Stichprobe_3 = as.numeric(sample3) / sample_size
)
data_y2$Mittel <- (data_y2$Stichprobe_1 + data_y2$Stichprobe_2 + data_y2$Stichprobe_3) / 3

barplot(as.matrix(data_y2),
        col = c("#e67e22", "#2980b9", "#f1c40f"),
        ylim = c(0, 1.45),
        legend.text = c("orange", "blau", "gelb"),
        args.legend = list(bty = "n", x = "topright"),
        main = paste("Stichprobengroesse", sample_size, ", Jahr 2"),
        ylab = "Anteil")

# F8
# - Warum ist Jahr 2 heikler als Jahr 1?
# - sample_size aendern.
# - Lieber viele kleine Stichproben oder eine grosse?

# --- Bonus: wen das Netz bevorzugt ---
#
# Gelbe Schleicher gehen seltener ins Netz, orange Maennchen leichter.
# bias sind Gewichte. rmultinom teilt sie durch ihre Summe.

lizard_pop_b <- c(0.25, 0.5, 0.25)   # orange, blau, gelb
bias <- c(1, 0.75, 0.5)

sample_size <- 20

set.seed(2026)
sample1 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_b * bias)
sample2 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_b * bias)
sample3 <- rmultinom(n = 1, size = sample_size, prob = lizard_pop_b * bias)

data_b <- data.frame(
  Wirklichkeit = lizard_pop_b,
  Stichprobe_1 = as.numeric(sample1) / sample_size,
  Stichprobe_2 = as.numeric(sample2) / sample_size,
  Stichprobe_3 = as.numeric(sample3) / sample_size
)
data_b$Mittel <- (data_b$Stichprobe_1 + data_b$Stichprobe_2 + data_b$Stichprobe_3) / 3

barplot(as.matrix(data_b),
        col = c("#e67e22", "#2980b9", "#f1c40f"),
        ylim = c(0, 1.45),
        legend.text = c("orange", "blau", "gelb"),
        args.legend = list(bty = "n", x = "topright"),
        main = paste("Mit Fangbias, n =", sample_size),
        ylab = "Anteil")

# Bonus. Wann wird der Fangbias zum Problem?
# Hilft ein groesseres sample_size, oder bleibt die Abweichung?

# ===========================================================================
# Fazit
# ===========================================================================
#
# Teil A aendert die Population. Teil B aendert nur, was im Netz liegt.
#
# F9. Saetze zu Ende schreiben.
# - In einer kleinen Population kann ein Allel zufaelligerweise ... . Das ist Drift.
# - Wenn wir Stichproben nehmen, koennen seltene Typen zufaelligerweise ... .
# - In Teich 7 wurden pro Jahr nur 7-36 Fische untersucht. Ein Teil des
#   Unterschieds zu den anderen Teichen kann deshalb ... sein.
