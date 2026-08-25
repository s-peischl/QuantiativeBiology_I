#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
dir <- if (length(file_arg)) dirname(normalizePath(file_arg)) else getwd()

candidates <- c(
  file.path(dir, "doi_10_5061_dryad_kprr4xhhn__v20250626", "Salo_et_al_predation.csv"),
  file.path(dir, "Salo_et_al_predation.csv")
)
raw <- candidates[file.exists(candidates)][1]
if (is.na(raw)) stop("Missing Salo_et_al_predation.csv under ", dir)

d <- read.csv(raw, sep = ";", stringsAsFactors = FALSE,
              check.names = FALSE, fileEncoding = "UTF-8-BOM")
# strip BOM / junk prefixes from names
names(d) <- tolower(gsub("^[^a-zA-Z]*", "", names(d)))
names(d) <- gsub("[^a-z0-9_]+", "_", names(d))

if (!("plate_phenotypes" %in% names(d)) && ("plate_phenotype" %in% names(d))) {
  d$plate_phenotypes <- d$plate_phenotype
}

need <- c("temperature", "predation", "shredder_biomass", "diatom_biomass")
miss <- setdiff(need, names(d))
if (length(miss)) {
  stop("Missing columns: ", paste(miss, collapse = ", "),
       "\nHave: ", paste(names(d), collapse = ", "))
}

out <- data.frame(
  temperature = d$temperature,
  predation = d$predation,
  plate_phenotypes = d$plate_phenotypes,
  waterbath = d$waterbath,
  shredder_biomass = as.numeric(d$shredder_biomass),
  diatom_biomass = as.numeric(d$diatom_biomass),
  gastropod_biomass = as.numeric(d$gastropod_biomass),
  data_type = "real_experimental",
  source = "Dryad doi:10.5061/dryad.kprr4xhhn (doi_10_5061_dryad_kprr4xhhn__v20250626/Salo_et_al_predation.csv)",
  citation = "Salo et al. (2025) Functional Ecology; https://doi.org/10.5061/dryad.kprr4xhhn",
  stringsAsFactors = FALSE
)

dest <- file.path(dir, "stickleback_foodweb.csv")
write.csv(out, dest, row.names = FALSE)
message("Read:  ", raw)
message("Wrote: ", dest, " (n = ", nrow(out), ")")
message("predation: ", paste(unique(out$predation), collapse = " | "))
print(aggregate(cbind(shredder_biomass, diatom_biomass) ~ predation, out, mean))
print(aggregate(cbind(shredder_biomass, diatom_biomass) ~ predation + temperature, out, mean))
