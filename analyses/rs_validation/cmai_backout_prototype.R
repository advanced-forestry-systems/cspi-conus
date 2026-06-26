#!/usr/bin/env Rscript
# cMAI back-out prototype (complementary to Aaron's active yield-curve work).
# Idea (Aaron's framing): compare biomass increment from remeasured plots against an
# idealized yield curve to recover culmination mean annual increment (cMAI). Here we use a
# Chapman-Richards biomass curve AGB(t) = Asym*(1 - exp(-k t))^p with p fixed; per plot we
# solve k from the current annual increment (BGI) at the current stand age, then compute
# cMAI = max_t AGB(t)/t and the culmination age. We then check cMAI against FIA SITECLCD
# (which is a binning of cubic-volume MAICF), to see whether a biomass-route cMAI reproduces
# the classification. Prototype only; p and the C-R form are assumptions to revisit.
set.seed(20260625)
suppressWarnings(suppressMessages({ library(data.table) }))
WORK <- "/fs/scratch/PUOM0008/crsfaaron/rs_validation"
F <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7/multidim_v2/plt_ext_4c_plus_FIA.csv"
say <- function(...) cat(sprintf("[%s] %s\n", format(Sys.time(),"%H:%M:%S"), paste0(...)))

d <- fread(F)
d <- d[is.finite(asym_v) & asym_v>0 & is.finite(bgi_v) & bgi_v>0 & is.finite(STDAGE) & STDAGE>=10 & STDAGE<=300]
say("plots with asym, bgi>0, age 10-300: ", nrow(d))

cmai_one <- function(A, I0, t0, p){
  # increment of A*(1-e^{-kt})^p : I(t)=A*p*(1-e^{-kt})^{p-1}*k*e^{-kt}
  fI <- function(k) A*p*(1-exp(-k*t0))^(p-1)*k*exp(-k*t0) - I0
  lo <- fI(1e-4); hi <- fI(0.5)
  if (is.na(lo)||is.na(hi)||lo*hi>0) return(c(NA,NA,NA))
  k <- tryCatch(uniroot(fI, c(1e-4,0.5))$root, error=function(e) NA)
  if (is.na(k)) return(c(NA,NA,NA))
  tt <- 1:300; mai <- A*(1-exp(-k*tt))^p / tt
  j <- which.max(mai)
  c(k, tt[j], mai[j])   # k, culmination age, cMAI
}
for (p in c(2,3)){
  m <- t(mapply(cmai_one, d$asym_v, d$bgi_v, d$STDAGE, MoreArgs=list(p=p)))
  d[[paste0("cMAI_p",p)]] <- m[,3]; d[[paste0("cAge_p",p)]] <- m[,2]
  say(sprintf("p=%d: solved %d/%d (%.0f%%); cMAI median %.2f Mg/ha/yr, culm age median %.0f",
      p, sum(is.finite(m[,3])), nrow(d), 100*mean(is.finite(m[,3])),
      median(m[,3],na.rm=TRUE), median(m[,2],na.rm=TRUE)))
}
fwrite(d[, .(LAT,LON,STDAGE,asym_v,bgi_v,SITECLCD,cMAI_p2,cAge_p2,cMAI_p3,cAge_p3)],
       file.path(WORK,"cMAI_backout_plots.csv"))

# alignment with SITECLCD (productivity-ordered: 8-class so higher = more productive)
ds <- d[SITECLCD %in% 1:7 & is.finite(cMAI_p3)]
ds[, prod_class := 8L - as.integer(SITECLCD)]
cor_tab <- data.table(
  comparison=c("cMAI_p3 vs prod_class","cMAI_p2 vs prod_class","bgi_v vs prod_class","asym_v vs prod_class"),
  spearman=c(cor(ds$cMAI_p3, ds$prod_class, method="spearman", use="complete.obs"),
             cor(ds$cMAI_p2, ds$prod_class, method="spearman", use="complete.obs"),
             cor(ds$bgi_v, ds$prod_class, method="spearman"),
             cor(ds$asym_v, ds$prod_class, method="spearman")))
fwrite(cor_tab, file.path(WORK,"cMAI_vs_siteclcd.csv"))
say("cMAI vs SITECLCD alignment:"); print(cor_tab)
# mean cMAI by site class
byc <- ds[, .(n=.N, mean_cMAI_p3=mean(cMAI_p3,na.rm=TRUE), mean_culm_age=mean(cAge_p3,na.rm=TRUE)), by=SITECLCD][order(SITECLCD)]
fwrite(byc, file.path(WORK,"cMAI_by_siteclass.csv")); say("mean cMAI by FIA site class:"); print(byc)
say("cMAI prototype complete."); cat("DONE\n", file=file.path(WORK,"_cmai_status.txt"))
