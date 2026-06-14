## v3 multidim: fix B4d (disturbance + treatment) + add new analyses
## C1: Disturbance effect (recent harvest, fire, insect/disease)
## C2: Treatment effect (recent treatment vs no treatment)
## C3: Stand size class effect
## C4: Per-state correlation (top 12 states by sample size)
## C5: Predict SITECLCD from components: which one wins?

suppressPackageStartupMessages({
  library(data.table); library(ranger)
})

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v3")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

## Load joined table
plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
cat("loaded", nrow(plt), "rows\n")

## Reconstruct STATECD from key (LAT_LON unique, need to look up)
FIA_DIR <- "/users/PUOM0008/crsfaaron/FIA"
cstates <- list.files(FIA_DIR, "_PLOT\\.csv$", full.names = FALSE)
cstates <- gsub("_PLOT.csv", "", cstates)
conus_states <- setdiff(cstates, c("AK","HI","PR","VI"))
plt_minimal_list <- list()
for (st in conus_states) {
  f <- file.path(FIA_DIR, paste0(st, "_PLOT.csv"))
  if (!file.exists(f)) next
  d <- fread(f, select = c("STATECD","LAT","LON"))
  if (nrow(d)) plt_minimal_list[[st]] <- d
}
plt_min <- rbindlist(plt_minimal_list)
plt_min[, key := paste0(round(LAT, 4), "_", round(LON, 4))]
plt_min <- unique(plt_min, by = "key")
plt <- merge(plt, plt_min[, .(key, STATECD)], by = "key", all.x = TRUE)
cat("plots with STATECD:", sum(!is.na(plt$STATECD)), "\n")

mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
plt[, z_esi  := pmax(pmin((esi    - mu$esi ) / sd$esi , 3), -3)]
plt[, z_bgi  := pmax(pmin((bgi_v  - mu$bgi ) / sd$bgi , 3), -3)]
plt[, z_asym := pmax(pmin((asym_v - mu$asym) / sd$asym, 3), -3)]
plt[, c3 := (z_esi + z_bgi + z_asym) / 3]
mm <- range(plt$c3, na.rm = TRUE)
plt[, cspi3 := (c3 - mm[1]) / (mm[2] - mm[1]) * 100]

## ===== C1: Disturbance =====
cat("\n=== C1: Disturbance effect ===\n")
# DSTRBCD1: 0=none, 10=insect, 20=disease, 30=fire, 40=animal, 50=weather, 60=vegetation, 70=unknown, 80=human, 90=storm
plt[, disturb_recent := !is.na(DSTRBCD1) & DSTRBCD1 > 0]
plt[, disturb_category := fcase(
  DSTRBCD1 >= 10 & DSTRBCD1 < 20, "Insect",
  DSTRBCD1 >= 20 & DSTRBCD1 < 30, "Disease",
  DSTRBCD1 >= 30 & DSTRBCD1 < 40, "Fire",
  DSTRBCD1 >= 40 & DSTRBCD1 < 50, "Animal",
  DSTRBCD1 >= 50 & DSTRBCD1 < 60, "Weather",
  DSTRBCD1 >= 60 & DSTRBCD1 < 70, "Vegetation",
  DSTRBCD1 >= 80 & DSTRBCD1 < 90, "Human",
  DSTRBCD1 >= 90 & DSTRBCD1 <= 99, "Storm",
  default = "None"
)]

dist_summary <- plt[, .(
  n           = .N,
  mean_esi    = round(mean(esi,    na.rm = TRUE), 1),
  mean_bgi    = round(mean(bgi_v,  na.rm = TRUE), 2),
  mean_asym   = round(mean(asym_v, na.rm = TRUE), 1),
  mean_npp    = round(mean(npp_v,  na.rm = TRUE), 0),
  mean_cspi   = round(mean(cspi3,  na.rm = TRUE), 1),
  r_esi_bgi   = round(cor(z_esi, z_bgi, use = "p"), 3)
), by = disturb_category][order(-n)]
cat("Disturbance category effect:\n")
print(dist_summary)
fwrite(dist_summary, file.path(OUT, "C1_disturbance_effect.csv"))

## ===== C2: Treatment =====
cat("\n=== C2: Treatment effect ===\n")
# TRTCD1: 00=none, 10=cutting, 20=site prep, 30=artificial regen, 40=natural regen, 50=other
plt[, treat_recent := !is.na(TRTCD1) & TRTCD1 > 0]
plt[, treat_category := fcase(
  is.na(TRTCD1) | TRTCD1 == 0, "None",
  TRTCD1 >= 10 & TRTCD1 < 20, "Cutting",
  TRTCD1 >= 20 & TRTCD1 < 30, "Site prep",
  TRTCD1 >= 30 & TRTCD1 < 40, "Artificial regen",
  TRTCD1 >= 40 & TRTCD1 < 50, "Natural regen",
  default = "Other"
)]

treat_summary <- plt[, .(
  n           = .N,
  mean_esi    = round(mean(esi,    na.rm = TRUE), 1),
  mean_bgi    = round(mean(bgi_v,  na.rm = TRUE), 2),
  mean_asym   = round(mean(asym_v, na.rm = TRUE), 1),
  mean_npp    = round(mean(npp_v,  na.rm = TRUE), 0),
  mean_cspi   = round(mean(cspi3,  na.rm = TRUE), 1),
  r_esi_bgi   = round(cor(z_esi, z_bgi, use = "p"), 3)
), by = treat_category][order(-n)]
cat("Treatment category effect:\n")
print(treat_summary)
fwrite(treat_summary, file.path(OUT, "C2_treatment_effect.csv"))

## ===== C3: Stand size class =====
cat("\n=== C3: Stand size class ===\n")
# STDSZCD: 1=large diameter, 2=medium diameter, 3=small diameter, 4=seedling/sapling, 5=non-stocked
plt[, std_size := fcase(
  STDSZCD == 1, "Large diameter",
  STDSZCD == 2, "Medium diameter",
  STDSZCD == 3, "Small diameter",
  STDSZCD == 4, "Seedling/sapling",
  STDSZCD == 5, "Non-stocked",
  default = NA_character_
)]

size_summary <- plt[!is.na(std_size),
  .(n           = .N,
    mean_esi    = round(mean(esi,    na.rm = TRUE), 1),
    mean_bgi    = round(mean(bgi_v,  na.rm = TRUE), 2),
    mean_asym   = round(mean(asym_v, na.rm = TRUE), 1),
    mean_npp    = round(mean(npp_v,  na.rm = TRUE), 0),
    mean_cspi   = round(mean(cspi3,  na.rm = TRUE), 1),
    r_esi_bgi   = round(cor(z_esi, z_bgi, use = "p"), 3)
  ), by = std_size]
print(size_summary)
fwrite(size_summary, file.path(OUT, "C3_stand_size_effect.csv"))

## ===== C4: Per-state correlations =====
cat("\n=== C4: Per-state correlations ===\n")
top_states <- sort(table(plt$STATECD), decreasing = TRUE)[1:15]
state_names <- c(`1`="AL", `5`="AR", `6`="CA", `8`="CO", `12`="FL", `13`="GA",
                 `16`="ID", `17`="IL", `18`="IN", `19`="IA", `20`="KS", `21`="KY",
                 `22`="LA", `23`="ME", `24`="MD", `25`="MA", `26`="MI", `27`="MN",
                 `28`="MS", `29`="MO", `30`="MT", `31`="NE", `32`="NV", `33`="NH",
                 `34`="NJ", `35`="NM", `36`="NY", `37`="NC", `38`="ND", `39`="OH",
                 `40`="OK", `41`="OR", `42`="PA", `44`="RI", `45`="SC", `46`="SD",
                 `47`="TN", `48`="TX", `49`="UT", `50`="VT", `51`="VA", `53`="WA",
                 `54`="WV", `55`="WI", `56`="WY", `9`="CT", `10`="DE", `4`="AZ")

state_summary <- plt[STATECD %in% as.integer(names(top_states)),
  .(state = state_names[as.character(unique(STATECD))],
    n         = .N,
    r_esi_bgi = round(cor(z_esi, z_bgi, use = "p"), 3),
    r_esi_asym = round(cor(z_esi, z_asym, use = "p"), 3),
    r_bgi_asym = round(cor(z_bgi, z_asym, use = "p"), 3),
    mean_cspi = round(mean(cspi3, na.rm = TRUE), 1)),
  by = STATECD][order(-n)]
print(state_summary)
fwrite(state_summary, file.path(OUT, "C4_per_state_correlations.csv"))

## ===== C5: Predict SITECLCD from components =====
cat("\n=== C5: Predict SITECLCD from components ===\n")
sub <- plt[!is.na(SITECLCD) & SITECLCD %in% 1:7]
# Try each measure alone, then all three, then composite
sub_use <- sub[complete.cases(sub[, .(esi, bgi_v, asym_v, SITECLCD)])]
cat("n:", nrow(sub_use), "\n")
set.seed(47)

predict_one <- function(target_col, predictor_cols) {
  preds <- paste(predictor_cols, collapse = " + ")
  m <- ranger(formula = as.formula(paste("SITECLCD ~", preds)),
              data = sub_use[, c("SITECLCD", predictor_cols), with = FALSE],
              num.trees = 500, num.threads = 8,
              classification = FALSE, importance = "impurity")
  data.table(predictors = paste(predictor_cols, collapse = ", "),
             n = nrow(sub_use),
             OOB_R2 = round(m$r.squared, 4),
             OOB_RMSE = round(sqrt(m$prediction.error), 3))
}

c5_results <- rbind(
  predict_one("SITECLCD", "esi"),
  predict_one("SITECLCD", "bgi_v"),
  predict_one("SITECLCD", "asym_v"),
  predict_one("SITECLCD", "npp_v"),
  predict_one("SITECLCD", "cspi3"),
  predict_one("SITECLCD", c("esi","bgi_v","asym_v")),
  predict_one("SITECLCD", c("esi","bgi_v","asym_v","npp_v"))
)
cat("R² predicting FIA SITECLCD from each measure (or set of measures):\n")
print(c5_results)
fwrite(c5_results, file.path(OUT, "C5_predict_SITECLCD.csv"))

cat("\n=== v3 multidim done. Outputs in", OUT, "===\n")
