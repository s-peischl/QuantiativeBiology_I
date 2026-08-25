library(gauseR)
dir3 <- "/Users/stephan/Dropbox/Teaching/BridgeCourse/Part1_HS/2026_HS/course-outline/weeks/week-03/data"

d <- gause_1934_book_app_t01
sc_alone <- subset(d, Treatment == "Monoculture" & Experiment == 1 &
                     grepl("Saccharomyces cerevisiae", Species))
sk_alone <- subset(d, Treatment == "Monoculture" & Experiment == 1 &
                     grepl("Schizosaccharomyces", Species))
sc_mix <- subset(d, Treatment == "Mixture" & Experiment == 1 &
                   grepl("Saccharomyces cerevisiae", Species))
sk_mix <- subset(d, Treatment == "Mixture" & Experiment == 1 &
                   grepl("Schizosaccharomyces", Species))

yeast_alone <- rbind(
  data.frame(hour = sc_alone$Time, species = "S. cerevisiae",
             volume = sc_alone$Volume_Species, treatment = "alone"),
  data.frame(hour = sk_alone$Time, species = "S. kephir",
             volume = sk_alone$Volume_Species, treatment = "alone")
)
yeast_alone <- yeast_alone[is.finite(yeast_alone$volume), ]
yeast_alone$source <- "gauseR::gause_1934_book_app_t01"
yeast_alone$citation <- "Gause (1934) Struggle for Existence, Appendix Table 1"

times <- sort(unique(c(sc_mix$Time, sk_mix$Time)))
yeast_mix <- data.frame(
  hour = times,
  cerevisiae = sc_mix$Volume_Species[match(times, sc_mix$Time)],
  kephir = sk_mix$Volume_Species[match(times, sk_mix$Time)],
  treatment = "mixture",
  source = "gauseR::gause_1934_book_app_t01",
  citation = "Gause (1934) Struggle for Existence, Appendix Table 1"
)

write.csv(yeast_alone, file.path(dir3, "yeast_alone.csv"), row.names = FALSE)
write.csv(yeast_mix, file.path(dir3, "yeast_competition.csv"), row.names = FALSE)

# Tribolium priority: teaching reconstruction of Costanzo et al. 2020 Fig. 3 means
trib <- rbind(
  data.frame(month = 1:7, treatment = "CS_priority",
             castaneum = c(11, 14, 18, 28, 42, 38, 22),
             confusum  = c(10,  9,  8,  6,  5,  5,  4)),
  data.frame(month = 1:7, treatment = "CF_priority",
             castaneum = c(10,  9,  8,  8,  9,  8,  8),
             confusum  = c(12, 13, 14, 15, 18, 20, 16)),
  data.frame(month = 1:7, treatment = "simultaneous",
             castaneum = c(10, 11, 12, 18, 55, 48,  8),
             confusum  = c(10, 10, 11, 12, 14, 12,  6))
)
trib$source <- "teaching reconstruction of treatment means"
trib$citation <- "Costanzo et al. (2020) PLoS ONE 15:e0236219 Fig. 3; approximate monthly means for teaching"
write.csv(trib, file.path(dir3, "tribolium_priority.csv"), row.names = FALSE)

cat("OK\n")
print(yeast_mix)
print(aggregate(cbind(castaneum, confusum) ~ treatment, trib, mean))
