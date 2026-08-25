#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-
# Regeneriert Lehrschemata für Woche 1 (UTF-8 + quartz auf macOS).

Sys.setlocale("LC_ALL", "en_US.UTF-8")
dir.create("pics/biology", showWarnings = FALSE, recursive = TRUE)

library(grid)
suppressPackageStartupMessages(library(ggplot2))

png_dev <- function(file, width, height, res = 140) {
  if (capabilities("aqua")) {
    png(file, width = width, height = height, res = res, type = "quartz")
  } else {
    png(file, width = width, height = height, res = res)
  }
}

# ---- O2 / Milzkontraktion ----
png_dev("pics/biology/spleen_o2_dive_schematic.png", 1600, 900, 140)
grid.newpage()
grid.text(
  "Milzkontraktion beim Apnoetauchen — O2-Schub",
  y = unit(0.95, "npc"), gp = gpar(fontsize = 18, fontface = "bold")
)
grid.circle(x = 0.18, y = 0.52, r = 0.12, gp = gpar(fill = "#e74c3c", col = "#922b21", lwd = 2))
grid.text("Milz\n(Ruhe)", x = 0.18, y = 0.52, gp = gpar(col = "white", fontface = "bold", fontsize = 12))
grid.text("Speicher:\nO2-reiche Erythrozyten", x = 0.18, y = 0.28, gp = gpar(fontsize = 10))
grid.lines(
  x = c(0.30, 0.38), y = c(0.52, 0.52),
  arrow = arrow(type = "closed", length = unit(0.25, "cm")),
  gp = gpar(lwd = 2.5, col = "#2c3e50", fill = "#2c3e50")
)
grid.text("Tauchen\n(Apnoe + Kaeltereiz)", x = 0.34, y = 0.64, gp = gpar(fontsize = 9))
grid.circle(x = 0.48, y = 0.52, r = 0.085, gp = gpar(fill = "#c0392b", col = "#641e16", lwd = 2))
grid.text("Milz\nkontrahiert", x = 0.48, y = 0.52, gp = gpar(col = "white", fontface = "bold", fontsize = 9))
grid.lines(
  x = c(0.57, 0.65), y = c(0.52, 0.52),
  arrow = arrow(type = "closed", length = unit(0.25, "cm")),
  gp = gpar(lwd = 2.5, col = "#2c3e50", fill = "#2c3e50")
)
grid.roundrect(
  x = 0.80, y = 0.52, width = 0.26, height = 0.32,
  gp = gpar(fill = "#fdebd0", col = "#b9770e", lwd = 2), r = unit(0.03, "npc")
)
grid.text("Freisetzung in\nden Kreislauf", x = 0.80, y = 0.60, gp = gpar(fontsize = 11, fontface = "bold"))
grid.text(
  "mehr O2-Transport\n-> laengeres Apnoe-\nTauchen moeglich",
  x = 0.80, y = 0.46, gp = gpar(fontsize = 10)
)
grid.roundrect(
  x = 0.5, y = 0.10, width = 0.86, height = 0.12,
  gp = gpar(fill = "#f7f7f7", col = "#bbbbbb"), r = unit(0.02, "npc")
)
grid.text(
  "Idee: groessere Milz = groesserer biologischer Sauerstofftank. Nach Ilardo et al. 2018 / Saeuger-Tauchreflex.",
  x = 0.5, y = 0.10, gp = gpar(fontsize = 10, col = "#333333")
)
dev.off()

# ---- Milzgrosse ----
df <- data.frame(
  Gruppe = factor(
    c("Saluan\n(nicht tauchend)", "Bajau\n(Population)"),
    levels = c("Saluan\n(nicht tauchend)", "Bajau\n(Population)")
  ),
  Index = c(1.0, 1.5)
)
p2 <- ggplot(df, aes(Gruppe, Index, fill = Gruppe)) +
  geom_col(width = 0.55, color = "black", show.legend = FALSE) +
  scale_fill_manual(values = c("#7f8c8d", "#2980b9")) +
  geom_text(aes(label = sprintf("%.1fx", Index)), vjust = -0.4, fontface = "bold", size = 5) +
  annotate("text", x = 1.5, y = 1.85, label = "ca. 50% groesser", color = "#c0392b", size = 4.5, fontface = "bold") +
  scale_y_continuous(limits = c(0, 2.05), expand = c(0, 0)) +
  labs(
    title = "Milzgrosse: Bajau vs. Saluan",
    subtitle = "Schematisch nach Ilardo et al. 2018 (Cell)",
    y = "Relative Milzgrosse (Index)", x = NULL,
    caption = "Lehrschema. Original-Boxplots: Ilardo et al. 2018 Cell (Urheberrecht Elsevier) - dort nachschlagen."
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(size = 8, color = "#444444", hjust = 0)
  )
png_dev("pics/biology/spleen_size_schematic.png", 1152, 864, 160)
print(p2)
dev.off()

message("OK schematics")
