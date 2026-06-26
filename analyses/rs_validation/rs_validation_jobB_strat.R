#!/usr/bin/env Rscript
# Job B: stratified robustness of the repeat-RS validation. Tests whether the
# BGI-tracks-flux / ESI-orthogonal pattern is stable across the East-West regime and
# latitude bands, adds a partial correlation (does observed NPP track BGI controlling
# for ESI), and renders a journal-ready ggplot heatmap. On-disk only. Seed set.
set.seed(20260621)
suppressWarnings(suppressMessages({ library(data.table); library(ggplot2) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
say <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))

# rebuild a deduped table that KEEPS coordinates (dedup file dropped LAT/LON)
dt <- fread(file.path(WORK, "plots_validation_joined.csv"))
keep <- c("ID","LAT","LON","SI","bgi","asym","npp_miami","cspi_4c_0100",
          "npp_obs","npp_obs_cv","gpp_obs","ch_m")
keep <- keep[keep %in% names(dt)]
dtu <- dt[, lapply(.SD, function(z) if (all(is.na(z))) NA_real_ else mean(z, na.rm=TRUE)),
          by = ID, .SDcols = setdiff(keep,"ID")]
say("unique plots = ", nrow(dtu))

dtu[, region := ifelse(LON < -100, "West", "East")]
dtu[, lat_band := cut(LAT, c(24,31,37,43,50), labels=c("24-31","31-37","37-43","43-50"))]

pairs <- list(c("bgi","gpp_obs"), c("bgi","npp_obs"), c("SI","npp_obs"),
              c("SI","gpp_obs"), c("asym","npp_obs_cv"), c("cspi_4c_0100","npp_obs"))
cc <- function(d, a, b){ ok <- is.finite(d[[a]])&is.finite(d[[b]])
  if (sum(ok) < 100) return(c(n=sum(ok), r=NA_real_))
  c(n=sum(ok), r=cor(d[[a]][ok], d[[b]][ok])) }

# by region
reg <- rbindlist(lapply(pairs, function(p) rbindlist(lapply(c("East","West"), function(g){
  v <- cc(dtu[region==g], p[1], p[2]); data.table(pair=paste(p[1],"vs",p[2]), stratum=g, n=v["n"], pearson=v["r"]) }))))
# by latitude band
latb <- rbindlist(lapply(pairs, function(p) rbindlist(lapply(levels(dtu$lat_band), function(g){
  v <- cc(dtu[lat_band==g], p[1], p[2]); data.table(pair=paste(p[1],"vs",p[2]), stratum=paste0("lat ",g), n=v["n"], pearson=v["r"]) }))))
strat <- rbind(reg, latb)
fwrite(strat, file.path(WORK, "RS_validation_stratified.csv"))
say("Stratified results:"); print(strat)

# partial correlation: NPP_obs ~ BGI controlling for ESI (and vice versa)
sub <- dtu[is.finite(npp_obs)&is.finite(bgi)&is.finite(SI)]
pc <- function(x,y,z){ rx <- resid(lm(x~z)); ry <- resid(lm(y~z)); cor(rx,ry) }
partial <- data.table(
  test = c("NPP_obs ~ BGI | ESI", "NPP_obs ~ ESI | BGI",
           "GPP_obs ~ BGI | ESI", "GPP_obs ~ ESI | BGI"),
  partial_r = c(pc(sub$npp_obs, sub$bgi, sub$SI), pc(sub$npp_obs, sub$SI, sub$bgi),
                pc(sub$gpp_obs, sub$bgi, sub$SI), pc(sub$gpp_obs, sub$SI, sub$bgi)),
  n = nrow(sub))
fwrite(partial, file.path(WORK, "RS_validation_partial.csv"))
say("Partial correlations:"); print(partial)

# journal-ready heatmap (full dedup correlation table)
ct <- fread(file.path(WORK, "RS_validation_correlations_dedup.csv"))
lab <- c(SI="ESI", bgi="BGI", asym="Asym", npp_miami="NPP(MIAMI)", cspi_4c_0100="Composite")
ct[, measure := factor(measure, levels=c("BGI","Composite","Asym","NPP_miami","ESI"))]
ct[, observed := factor(observed, levels=c("GPP_obs","NPP_obs","NPP_obs_CV","CanopyHt_LF2023"),
   labels=c("Obs GPP","Obs NPP","NPP interann. CV","Canopy ht (LF2023)"))]
g <- ggplot(ct, aes(observed, measure, fill=pearson)) +
  geom_tile(color="white", linewidth=0.6) +
  geom_text(aes(label=sprintf("%.2f", pearson)), size=3.6) +
  scale_fill_gradient2(low="#2c7bb6", mid="grey95", high="#d7191c", midpoint=0, limits=c(-0.8,0.8), name="Pearson r") +
  labs(x=NULL, y=NULL, title="Productivity measures vs observed repeat / structural remote sensing",
       subtitle=sprintf("FIA plots, deduplicated (n = %d; canopy height n = %d forested)", 38978, 29089)) +
  theme_minimal(base_size=12) +
  theme(axis.text.x=element_text(angle=20, hjust=1), panel.grid=element_blank(),
        plot.title=element_text(face="bold", size=12))
ggsave(file.path(WORK, "F_rs_validation_heatmap_journal.png"), g, width=8, height=4.2, dpi=300)
say("Job B complete"); cat("DONE\n", file=file.path(WORK,"_jobB_status.txt"))
