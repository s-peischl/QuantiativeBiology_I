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

# 2 · Beide Lösungen für den Winter liegen übereinander
png("ta-figs/zwei_loesungen.png", width = 1500, height = 900, res = 200)
zeige_clines(main = "Winter: zwei Erklärungen, fast dieselbe Kurve")
lines(x, simuliere_cline(0.1, 0.1), col = "grey60", lwd = 2, lty = 3)
lines(x, simuliere_cline(0.02, 0.1), col = "black", lwd = 2.4)
lines(x, simuliere_cline(0.1, 0.5), col = "#e7298a", lwd = 2.4, lty = 2)
legend("bottomright", bty = "n", lwd = c(2, 2.4, 2.4), lty = c(3, 1, 2),
       col = c("grey60", "black", "#e7298a"),
       legend = c("Sommer-Modell: s = 0.1, m = 0.1",
                  "A: s = 0.02, m = 0.1  (m/s = 5)",
                  "B: s = 0.1, m = 0.5  (m/s = 5)"))
dev.off()

# 3 · Abstand zum Winter hängt nur von m/s ab
s_werte <- c(0.1, 0.05, 0.033, 0.025, 0.02, 0.0167, 0.0125, 0.01)
m_werte <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0)
a_s <- sapply(s_werte, function(s) abstand_winter(simuliere_cline(s, 0.1)))
a_m <- sapply(m_werte, function(m) abstand_winter(simuliere_cline(0.1, m)))
png("ta-figs/abstand_ms.png", width = 1500, height = 900, res = 200)
plot(0.1 / s_werte, a_s, type = "b", pch = 16, col = "black", log = "x",
     ylim = c(0, max(a_s, a_m)), xlab = "m/s (log)",
     ylab = "Abstand zu den Winter-Daten",
     main = "Versuch A und B fallen auf eine Kurve")
lines(m_werte / 0.1, a_m, type = "b", pch = 17, col = "#e7298a", lty = 2)
abline(v = 5, lty = 3, col = "grey50")
legend("topright", bty = "n", pch = c(16, 17), lty = c(1, 2),
       col = c("black", "#e7298a"),
       legend = c("A: nur s verändert (m = 0.1)", "B: nur m verändert (s = 0.1)"))
dev.off()
print(tab); print(round(rbind(ms_A = 0.1 / s_werte, a_s, ms_B = m_werte / 0.1, a_m), 3))
