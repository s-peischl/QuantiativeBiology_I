#!/usr/bin/env Rscript
# Generate Week 1 teaching schematics (spleen, O2, Bajau locator).

dir.create("pics/biology", showWarnings = FALSE, recursive = TRUE)
dir.create("pics/bajau", showWarnings = FALSE, recursive = TRUE)

suppressPackageStartupMessages({
  library(ggplot2)
  library(grid)
})

# ---- 1) Locator map (schematic) ----
lands <- data.frame(
  xmin = c(95, 100, 109, 118, 118),
  xmax = c(107, 118, 121, 126, 132),
  ymin = c(5, -9, -5, 4, -9),
  ymax = c(20, 1, 3, 16, -1)
)
pts <- data.frame(
  x = c(123.5, 118.6, 121),
  y = c(-5.5, 4.5, 7),
  lab = c("Wakatobi (Sampela)", "Sabah / Semporna", "Sulu-See")
)
th <- seq(0, 2 * pi, length.out = 120)
ang <- -20 * pi / 180
ell <- data.frame(
  x = 120 + 11 * cos(th) * cos(ang) - 7 * sin(th) * sin(ang),
  y = 3 + 11 * cos(th) * sin(ang) + 7 * sin(th) * cos(ang)
)

p <- ggplot() +
  geom_rect(
    data = lands, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = "#d6e8c8", color = "#6a8f5a", linewidth = 0.6
  ) +
  geom_polygon(
    data = ell, aes(x, y),
    fill = "#2a6fbb", alpha = 0.28, color = "#0f3d6e", linewidth = 1
  ) +
  geom_point(data = pts, aes(x, y), color = "#c0392b", size = 3) +
  geom_text(
    data = pts, aes(x, y, label = lab),
    hjust = -0.1, vjust = 1.1, size = 3, color = "#6b1a12"
  ) +
  annotate(
    "label", x = 130, y = 14,
    label = "Kernregion der\nBajau / Sama-Bajau\n(insulares SE-Asien)",
    size = 3.5, fill = "white", color = "#0f3d6e", label.size = 0.4
  ) +
  annotate(
    "segment", x = 128, y = 12.5, xend = 124, yend = 6, color = "#0f3d6e",
    arrow = arrow(length = unit(0.2, "cm"))
  ) +
  coord_fixed(xlim = c(95, 140), ylim = c(-12, 22), expand = FALSE) +
  labs(
    title = "Wo leben die Bajau? (Lehrkarte, vereinfacht)",
    x = "Länge (°O) — schematisch",
    y = "Breite (°N) — schematisch",
    caption = "Schematische Orientierungskarte für den Unterricht — keine genaue Verbreitungsgrenze."
  ) +
  theme_bw(base_size = 12) +
  theme(
    panel.background = element_rect(fill = "#e8f4fc", colour = "#e8f4fc"),
    plot.background = element_rect(fill = "white", colour = "white"),
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )
ggsave("pics/bajau/bajau_locator_map.png", p, width = 9, height = 7, dpi = 160, bg = "white")

# ---- 2) Spleen size ----
df <- data.frame(
  Gruppe = factor(
    c("Saluan\n(nicht tauchend)", "Bajau\n(Population)"),
    levels = c("Saluan\n(nicht tauchend)", "Bajau\n(Population)")
  ),
  Index = c(1.0, 1.5)
)
p2 <- ggplot(df, aes(Gruppe, Index, fill = Gruppe)) +
  geom_col(width = 0.55, color = "black", linewidth = 0.4, show.legend = FALSE) +
  scale_fill_manual(values = c("#7f8c8d", "#2980b9")) +
  geom_text(aes(label = sprintf("%.1f×", Index)), vjust = -0.4, fontface = "bold", size = 5) +
  annotate("text", x = 1.5, y = 1.85, label = "≈ 50 % grösser", color = "#c0392b", size = 4.5, fontface = "bold") +
  annotate(
    "segment", x = 1.15, y = 1.78, xend = 2, yend = 1.55, color = "#c0392b",
    arrow = arrow(length = unit(0.2, "cm"))
  ) +
  scale_y_continuous(limits = c(0, 2.05), expand = c(0, 0)) +
  labs(
    title = "Milzgrösse: Bajau vs. Saluan",
    subtitle = "Schematisch nach Ilardo et al. 2018 (Cell) — Verhältnis ≈ +50 %",
    y = "Relative Milzgrösse (Index)", x = NULL,
    caption = paste(
      "Lehrschema. Original-Boxplots/Statistik: Ilardo et al. 2018 (Cell)",
      "— dort nachschlagen (Urheberrecht Elsevier)."
    )
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(size = 8, color = "#444", hjust = 0)
  )
ggsave("pics/biology/spleen_size_schematic.png", p2, width = 7.2, height = 5.4, dpi = 160, bg = "white")

# ---- 3) Spleen O2 diagram ----
png("pics/biology/spleen_o2_dive_schematic.png", width = 1600, height = 900, res = 140)
grid.newpage()
grid.text(
  "Milzkontraktion beim Apnoetauchen — O₂-Schub",
  y = unit(0.95, "npc"), gp = gpar(fontsize = 18, fontface = "bold")
)
grid.circle(x = 0.18, y = 0.52, r = 0.12, gp = gpar(fill = "#e74c3c", col = "#922b21", lwd = 2))
grid.text("Milz\n(Ruhe)", x = 0.18, y = 0.52, gp = gpar(col = "white", fontface = "bold", fontsize = 12))
grid.text("Speicher:\nO₂-reiche Erythrozyten", x = 0.18, y = 0.28, gp = gpar(fontsize = 10))
grid.lines(
  x = c(0.30, 0.38), y = c(0.52, 0.52),
  arrow = arrow(type = "closed", length = unit(0.25, "cm")),
  gp = gpar(lwd = 2.5, col = "#2c3e50", fill = "#2c3e50")
)
grid.text("Tauchen\n(Apnoe + Kältereiz)", x = 0.34, y = 0.64, gp = gpar(fontsize = 9))
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
  "mehr O₂-Transport\n→ längeres Apnoe-\nTauchen möglich",
  x = 0.80, y = 0.46, gp = gpar(fontsize = 10)
)
grid.roundrect(
  x = 0.5, y = 0.10, width = 0.86, height = 0.12,
  gp = gpar(fill = "#f7f7f7", col = "#bbbbbb"), r = unit(0.02, "npc")
)
grid.text(
  "Idee: grössere Milz ≈ grösserer «biologischer Sauerstofftank».  Nach Ilardo et al. 2018 / Säuger-Tauchreflex.",
  x = 0.5, y = 0.10, gp = gpar(fontsize = 10, col = "#333333")
)
dev.off()

# ---- 4) Annotate SE Asia orthographic ----
if (requireNamespace("png", quietly = TRUE) && file.exists("pics/bajau/se_asia_orthographic.png")) {
  img <- png::readPNG("pics/bajau/se_asia_orthographic.png")
  png("pics/bajau/bajau_on_se_asia_map.png", width = 1400, height = 1400, res = 140)
  grid.newpage()
  grid.raster(img, width = unit(1, "npc"), height = unit(1, "npc"))
  theta <- seq(0, 2 * pi, length.out = 200)
  cx <- 0.55
  cy <- 0.48
  rx <- 0.16
  ry <- 0.14
  grid.lines(
    x = cx + rx * cos(theta), y = cy + ry * sin(theta),
    default.units = "npc",
    gp = gpar(col = "#c0392b", lwd = 3, lty = "dashed")
  )
  grid.text(
    "Bajau-Region\n(Philippinen–Borneo–Sulawesi–Ostindonesien)",
    x = cx, y = cy - ry - 0.06,
    gp = gpar(col = "#c0392b", fontsize = 12, fontface = "bold"),
    just = "top"
  )
  grid.text(
    "Südostasien — ungefähre Bajau-Verbreitung\n(Orthographische Projektion + Markierung für den Unterricht)",
    x = 0.5, y = 0.97, gp = gpar(fontsize = 13, fontface = "bold")
  )
  grid.text(
    "Basiskarte: Wikimedia Commons (CC BY-SA 3.0). Markierung: Kursmaterial.",
    x = 0.5, y = 0.02, gp = gpar(fontsize = 8, col = "#444444")
  )
  dev.off()
}

message("Wrote Week 1 schematics.")
