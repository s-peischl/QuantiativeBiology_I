# Abbildungen für das TA-Merkblatt Woche 8 (Checkpoint B)
# Aufruf aus dem Repo-Root: Rscript scripts/make_week08_ta_figs.R
setwd("weeks/week-08")
src <- readLines("notebook.R")
ende <- grep("^# 1 · Abbildung 1", src) - 2
eval(parse(text = src[1:ende]))   # nur Daten und Funktionen

# 1 · Daten mit angepassten Kurven (wie Abbildung 1 der Studierenden)
png("ta-figs/abb1_clines.png", width = 1500, height = 900, res = 200)
tab <- vergleiche_clines()
dev.off()

# 2 · Drei Lösungen für den Winter liegen übereinander (alle m/s = 5)
png("ta-figs/winter_modelle.png", width = 1500, height = 900, res = 200)
zeige_clines(main = "Winter: drei Modelle mit m/s = 5, fast dieselbe Kurve")
lines(x, simuliere_cline(0.1, 0.1), col = "grey60", lwd = 2, lty = 3)
lines(x, simuliere_cline(0.02, 0.1), col = "black", lwd = 2.4)
lines(x, simuliere_cline(0.1, 0.5), col = "#e7298a", lwd = 2.4, lty = 2)
lines(x, simuliere_cline(0.01, 0.05), col = "#1b9e77", lwd = 2.4, lty = 4)
legend("bottomright", bty = "n", lwd = c(2, 2.4, 2.4, 2.4), lty = c(3, 1, 2, 4),
       col = c("grey60", "black", "#e7298a", "#1b9e77"), cex = 0.85,
       legend = c("Sommer-Modell: s = 0.1, m = 0.1",
                  "Lösung 1: s = 0.02, m = 0.1",
                  "Lösung 2: s = 0.1, m = 0.5",
                  "weniger Flug: s = 0.01, m = 0.05"))
dev.off()

# 3 · Weniger Flug (m = 0.05) allein macht die Cline enger
png("ta-figs/versuch_d.png", width = 1500, height = 900, res = 200)
zeige_clines(main = "Winter mit m = 0.05 (Mücken fliegen weniger)")
lines(x, simuliere_cline(0.1, 0.05), col = "#7570b3", lwd = 2.4, lty = 2)
lines(x, simuliere_cline(0.01, 0.05), col = "#1b9e77", lwd = 2.4)
legend("bottomright", bty = "n", lwd = 2.4, lty = c(2, 1),
       col = c("#7570b3", "#1b9e77"), cex = 0.85,
       legend = c("s = 0.1: enger als Sommer", "s = 0.01: passt zum Winter"))
dev.off()

# 4 · Abstand zum Winter hängt nur von m/s ab
s_werte <- c(0.1, 0.05, 0.033, 0.025, 0.02, 0.0167, 0.0125, 0.01)
m_werte <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0)
s_d     <- c(0.05, 0.025, 0.0167, 0.0125, 0.01, 0.0083, 0.00625, 0.005)
a_s <- sapply(s_werte, function(s) abstand(simuliere_cline(s, 0.1), winter))
a_m <- sapply(m_werte, function(m) abstand(simuliere_cline(0.1, m), winter))
a_d <- sapply(s_d, function(s) abstand(simuliere_cline(s, 0.05), winter))
png("ta-figs/abstand_ms.png", width = 1500, height = 900, res = 200)
plot(0.1 / s_werte, a_s, type = "b", pch = 16, col = "black", log = "x",
     ylim = c(0, max(a_s, a_m, a_d)), xlab = "m/s (log)",
     ylab = "Abstand zu den Winter-Daten",
     main = "Alle Winter-Lösungen fallen auf eine Kurve")
lines(m_werte / 0.1, a_m, type = "b", pch = 17, col = "#e7298a", lty = 2)
lines(0.05 / s_d, a_d, type = "b", pch = 15, col = "#1b9e77", lty = 4)
abline(v = 5, lty = 3, col = "grey50")
legend("topright", bty = "n", pch = c(16, 17, 15), lty = c(1, 2, 4),
       col = c("black", "#e7298a", "#1b9e77"), cex = 0.85,
       legend = c("nur s (m = 0.1)", "nur m (s = 0.1)", "s mit m = 0.05"))
dev.off()
p_kl <- simuliere_cline(0.1, 0.05)
print(tab)
cat("D s=0.1:", abstand(p_kl, sommer), abstand(p_kl, winter), "\n")
for (sm in list(c(.05,.05), c(.2,.2))) { p <- simuliere_cline(sm[1], sm[2]); cat(sm, abstand(p, sommer), "\n") }
print(round(rbind(ms = 0.1 / s_werte, a_s, ms_C = m_werte / 0.1, a_m, ms_D = 0.05 / s_d, a_d), 3))
