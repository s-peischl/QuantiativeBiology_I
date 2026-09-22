# Shared ggplot helpers for silent lecture figures (echo: false).
# Do not use in student notebooks — those stay in base R.
suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

col_blue <- "#2e86ab"
col_orange <- "#e67e22"
col_green <- "#27ae60"
col_navy <- "#2980b9"
col_grass <- "#d68910"
col_forest <- "#1e8449"
col_mussel <- "#f5b041"
col_other <- "#1abc9c"

theme_slide <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(size = 14, face = "plain", hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#eef2f5", linewidth = 0.35),
      axis.title = element_text(size = 12),
      legend.position = "top",
      legend.title = element_blank(),
      legend.margin = margin(0, 0, -4, 0),
      strip.text = element_text(size = 13),
      strip.background = element_blank(),
      plot.margin = margin(2, 8, 2, 2)
    )
}

# Long form for two-species time series (columns time, N1, N2).
ts_long <- function(sim, start, names = c("N1", "N2")) {
  data.frame(
    time = c(sim$time, sim$time),
    N = c(sim[[2]], sim[[3]]),
    art = factor(rep(names, each = nrow(sim)), levels = names),
    start = start
  )
}

plot_n_ts <- function(df, cols, title = "", ylab = "N", ylim = c(0, 100)) {
  nspec <- ncol(df) - 1
  long <- data.frame(
    time = rep(df$time, nspec),
    N = unlist(df[, -1, drop = FALSE], use.names = FALSE),
    art = factor(rep(names(df)[-1], each = nrow(df)), levels = names(df)[-1])
  )
  ggplot(long, aes(time, N, colour = art)) +
    geom_line(linewidth = 1.0) +
    scale_colour_manual(values = cols) +
    coord_cartesian(ylim = ylim) +
    labs(x = "Zeit", y = ylab, title = title) +
    theme_slide()
}

plot_two_ts <- function(df, cols, ylab = "N", ylim = c(0, 110)) {
  ggplot(df, aes(time, N, colour = art)) +
    geom_line(linewidth = 1.05) +
    scale_colour_manual(values = cols) +
    coord_cartesian(ylim = ylim) +
    facet_wrap(~ start, ncol = 2) +
    labs(x = "Zeit", y = ylab) +
    theme_slide()
}

simplex_verts <- function() {
  data.frame(x = c(0.5, 0, 1), y = c(sqrt(3) / 2, 0, 0))
}

to_simplex_xy <- function(N) {
  N <- as.matrix(N)
  s <- pmax(rowSums(N), 1e-12)
  f <- N / s
  v1 <- c(0.5, sqrt(3) / 2)
  v2 <- c(0, 0)
  v3 <- c(1, 0)
  data.frame(
    x = f[, 1] * v1[1] + f[, 2] * v2[1] + f[, 3] * v3[1],
    y = f[, 1] * v1[2] + f[, 2] * v2[2] + f[, 3] * v3[2],
    t = seq_len(nrow(N))
  )
}

plot_simplex <- function(df_N = NULL, title = "", labels = c("1", "2", "3")) {
  v <- simplex_verts()
  cols <- c("#e67e22", "#2980b9", "#f1c40f")
  p <- ggplot() +
    geom_polygon(
      data = v, aes(x, y),
      fill = "#f4f6f7", colour = "#2c3e50", linewidth = 0.7
    ) +
    coord_equal(xlim = c(-0.12, 1.12), ylim = c(-0.16, sqrt(3) / 2 + 0.14)) +
    theme_void() +
    theme(plot.title = element_text(size = 13, hjust = 0.5)) +
    labs(title = title) +
    annotate("text", x = 0.5, y = sqrt(3) / 2 + 0.07,
             label = labels[1], colour = cols[1], fontface = "bold") +
    annotate("text", x = -0.04, y = -0.06,
             label = labels[2], colour = cols[2], fontface = "bold") +
    annotate("text", x = 1.04, y = -0.06,
             label = labels[3], colour = cols[3], fontface = "bold")
  if (is.null(df_N)) return(p)
  xy <- to_simplex_xy(df_N)
  p +
    geom_path(
      data = xy, aes(x, y, colour = t),
      linewidth = 0.85, show.legend = FALSE
    ) +
    geom_point(data = xy[1, ], aes(x, y), colour = "#27ae60", size = 2) +
    geom_point(
      data = xy[nrow(xy), ], aes(x, y),
      colour = "#c0392b", size = 1.8
    ) +
    scale_colour_gradient(low = "#d5d8dc", high = "#1c2833")
}
