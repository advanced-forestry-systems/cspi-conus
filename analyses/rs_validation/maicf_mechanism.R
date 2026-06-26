#!/usr/bin/env Rscript
# MAICF mechanism: David Diaz's FIA correspondence shows SITECLCD is a classification of
# MAICF (mean annual increment of cubic volume at culmination), derived from site index via
# species-specific yield equations. This tests whether the classification encodes volume /
# biomass-growth structure (BGI) beyond the reported height site index (SICOND), and whether
# the species-specific transform is the bridge. Nested RF + residual correlation + species
# dependence. Seed set; OOB R^2 reported (in-sample-family, stated as such).
set.seed(20260625)
suppressWarnings(suppressMessages({ library(data.table); library(ranger) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
F <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v2/plt_ext_4c_plus_FIA.csv"
say <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))

d <- fread(F)
d <- d[SITECLCD %in% 1:7 & is.finite(SICOND) & SICOND > 0 & is.finite(esi) & is.finite(bgi_v) & is.finite(asym_v)]
# productivity-ordered class: 1=highest..7=lowest -> reverse so higher = more productive
d[, prod_class := 8L - as.integer(SITECLCD)]
d[, sp := factor(SISP)]
say("n = ", nrow(d), " ; species = ", nlevels(d$sp))

oobR2 <- function(form, data, ...) {
  m <- ranger(form, data = data, num.trees = 500, num.threads = 4, seed = 1, ...)
  m$r.squared
}
res <- data.table(
  model = c("SICOND (reported height SI)","ESI (unified height SI)","BGI (biomass growth)",
            "Asym","SICOND + species","SICOND + ESI","SICOND + BGI","SICOND + ESI + BGI + Asym"),
  oob_r2 = c(
    oobR2(prod_class ~ SICOND, d),
    oobR2(prod_class ~ esi, d),
    oobR2(prod_class ~ bgi_v, d),
    oobR2(prod_class ~ asym_v, d),
    oobR2(prod_class ~ SICOND + sp, d),
    oobR2(prod_class ~ SICOND + esi, d),
    oobR2(prod_class ~ SICOND + bgi_v, d),
    oobR2(prod_class ~ SICOND + esi + bgi_v + asym_v, d)))
res[, gain_over_SICOND := round(oob_r2 - oob_r2[1], 4)]
fwrite(res, file.path(WORK, "MAICF_nested_rf.csv"))
say("Nested RF predicting FIA site class:"); print(res)

# Residualize site class on SICOND (linear), correlate residual with BGI vs ESI
d[, resid_sc := residuals(lm(prod_class ~ SICOND, d))]
partial <- data.table(
  comparison = c("resid(class|SICOND) vs BGI","resid(class|SICOND) vs ESI","resid(class|SICOND) vs Asym"),
  pearson = c(cor(d$resid_sc, d$bgi_v), cor(d$resid_sc, d$esi), cor(d$resid_sc, d$asym_v)),
  spearman = c(cor(d$resid_sc, d$bgi_v, method="spearman"),
               cor(d$resid_sc, d$esi, method="spearman"),
               cor(d$resid_sc, d$asym_v, method="spearman")))
fwrite(partial, file.path(WORK, "MAICF_residual_corr.csv"))
say("What the site class adds beyond reported SICOND tracks:"); print(partial)

# Species dependence of the SICOND -> class mapping: within SICOND deciles, spread of mean
# class across the most common species
d[, sicond_dec := cut(SICOND, quantile(SICOND, 0:10/10), include.lowest=TRUE, labels=FALSE)]
topsp <- d[, .N, by=sp][order(-N)][1:8, sp]
sd_tab <- d[sp %in% topsp & !is.na(sicond_dec),
            .(mean_class = mean(prod_class), n=.N), by=.(sicond_dec, sp)]
spread <- sd_tab[, .(class_spread_across_species = max(mean_class) - min(mean_class),
                     n_species = uniqueN(sp)), by = sicond_dec][order(sicond_dec)]
fwrite(spread, file.path(WORK, "MAICF_species_spread.csv"))
say("Across-species spread of mean site class within SICOND deciles (the volume transform):")
print(spread)

# headline reproduction for consistency (BGI alone vs ESI alone OOB R2 on raw SITECLCD 1:7)
hl <- data.table(model=c("SITECLCD ~ BGI","SITECLCD ~ ESI"),
                 oob_r2=c(oobR2(as.integer(SITECLCD) ~ bgi_v, d),
                          oobR2(as.integer(SITECLCD) ~ esi, d)))
fwrite(hl, file.path(WORK,"MAICF_headline_check.csv"))
say("Headline check (raw SITECLCD):"); print(hl)
say("MAICF mechanism analysis complete."); cat("DONE\n", file=file.path(WORK,"_maicf_status.txt"))
