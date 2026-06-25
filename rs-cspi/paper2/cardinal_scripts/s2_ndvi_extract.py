#!/usr/bin/env python3
# Sentinel-2 growing-season mean NDVI/EVI at FIA plot locations via GEE.
# Service account already configured. Writes incremental CSV so it is resumable.
import ee, csv, os, sys, time

KEY = "/users/PUOM0008/crsfaaron/.config/earthengine/service_account.json"
ee.Initialize(ee.ServiceAccountCredentials("sae-followon-runner@sae-followon.iam.gserviceaccount.com", KEY),
              project="sae-followon")

PLOTS = "/fs/scratch/PUOM0008/crsfaaron/rs_validation/plots_validation_joined.csv"
OUT   = "/fs/scratch/PUOM0008/crsfaaron/rs_target/s2_ndvi/plots_s2.csv"
os.makedirs(os.path.dirname(OUT), exist_ok=True)

# read plot id/lon/lat
rows = []
with open(PLOTS) as f:
    r = csv.DictReader(f)
    for d in r:
        rows.append((d["ID"], float(d["LON"]), float(d["LAT"])))

done = set()
if os.path.exists(OUT):
    with open(OUT) as f:
        for d in csv.DictReader(f):
            done.add(d["ID"])
print(f"plots {len(rows)}, already done {len(done)}", flush=True)

def s2_composite():
    def mask(img):
        scl = img.select("SCL")
        good = scl.neq(3).And(scl.neq(8)).And(scl.neq(9)).And(scl.neq(10)).And(scl.neq(11))
        return img.updateMask(good)
    ic = (ee.ImageCollection("COPERNICUS/S2_SR_HARMONIZED")
          .filterDate("2021-06-01","2021-09-30")
          .filter(ee.Filter.lt("CLOUDY_PIXEL_PERCENTAGE",60))
          .map(mask))
    def addvi(img):
        ndvi = img.normalizedDifference(["B8","B4"]).rename("NDVI")
        evi = img.expression("2.5*((N-R)/(N+6*R-7.5*B+1))",
              {"N":img.select("B8").divide(10000),"R":img.select("B4").divide(10000),
               "B":img.select("B2").divide(10000)}).rename("EVI")
        return img.addBands([ndvi,evi])
    return ic.map(addvi).select(["NDVI","EVI"]).mean()

comp = s2_composite()
todo = [x for x in rows if x[0] not in done]
print(f"remaining {len(todo)}", flush=True)

CHUNK = 500
write_header = not os.path.exists(OUT)
with open(OUT, "a", newline="") as fo:
    w = csv.writer(fo)
    if write_header: w.writerow(["ID","ndvi_s2","evi_s2"])
    for i in range(0, len(todo), CHUNK):
        chunk = todo[i:i+CHUNK]
        feats = [ee.Feature(ee.Geometry.Point([lon,lat]), {"ID":pid}) for pid,lon,lat in chunk]
        fc = ee.FeatureCollection(feats)
        sampled = comp.reduceRegions(collection=fc, reducer=ee.Reducer.mean(), scale=30, tileScale=16)
        for attempt in range(4):
            try:
                res = sampled.getInfo()["features"]; break
            except Exception as e:
                print(f"  retry {attempt} chunk {i}: {e}", flush=True); time.sleep(10)
        else:
            print(f"  FAILED chunk {i}", flush=True); continue
        for ft in res:
            p = ft["properties"]
            w.writerow([p.get("ID"), p.get("NDVI"), p.get("EVI")])
        fo.flush()
        print(f"  chunk {i}-{i+len(chunk)} done", flush=True)
print("S2 NDVI extraction DONE", flush=True)
