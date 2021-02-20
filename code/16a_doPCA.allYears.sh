#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J doPCA
#SBATCH -e 16a_doPCA.allYears.%j.err
#SBATCH -o 16a_doPCA.allYears.%j.out
#SBATCH -c 20
#SBATCH --time=4-20:00:00
#SBATCH --mem=60G

set -e # exits upon failing command
set -v # verbose -- all lines

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="${data_dir}/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
PCA_dir="${data_dir}/RAD_PCA"

# need to use a more recent version
#module load angsd

mkdir -p ${PCA_dir}
cd ${PCA_dir}

### Make bamlist
ls ${RAD_dir}/*.proper.rmdup.bam > ${pop}.bamlist
nInd=$(wc -l ${pop}.bamlist | awk '{print $1}')
mInd=$((${nInd}/2))


#############################
###  for all generations  ###
#############################

### Calculate covariance matrix from randomly sampling a single read for each site for each individual	 ###
### 	and create a 0 or 1 matrix to calc cov matrix from 						 ###

	angsd -bam ${pop}.bamlist -out ${pop}_pca -doMajorMinor 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-12 -GL 1 -doMaf 1 -minInd ${mInd} -minMaf 0.05 -doCov 1 -doIBS 1 -doCounts 1


## Need to remove year 0 when plotting
