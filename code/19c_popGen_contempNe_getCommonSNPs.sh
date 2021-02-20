#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J comSNPs
#SBATCH -e 19c_popGen_contempNe_getCommonSNPs.%j.err
#SBATCH -o 19c_popGen_contempNe_getCommonSNPs.%j.out
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=MaxMemPerNode

set -e
set -x

# NOTES
# This script will retrive all the SNPs consistent in all the years and weed out years with too few individuals.

# set up directories
pop="DS_history"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
out_dir="${data_dir}/popgen_getMAFs"

ref="${para_dir}/DS_history_contigs_250.fasta"
noPara="${PARA_dir}/DS_history.rand20.same.29.loci"
noHybs="${PCA_dir}/Refined_Individuals.list"
yearList="${para_dir}/year.list"


Rscript ${code_dir}/popgen_getCommonSNPs.R #make to have options

