#!/bin/bash
#SBATCH --job-name=multidim_v3
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --account=PUOM0008
#SBATCH --output=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/multidim_v3_%j.out
#SBATCH --error=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/multidim_v3_%j.err
module load gcc/12.3.0 gdal/3.7.3 geos/3.12.0 proj/9.2.1 R/4.4.0
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/multidim_v3_analyses.r
