#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J doPCA
#SBATCH -e 16a_doPCA.allYears.noMinMAF.refined.%j.err
#SBATCH -o 16a_doPCA.allYears.noMinMAF.refined.%j.out
#SBATCH -c 20
#SBATCH --time=3-20:00:00
#SBATCH --mem=60G

# ONLY RUN THIS AFTER INITIAL PCA with NO MIN MAF

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
module load bio

cd ${PCA_dir}

### Make bamlist from individuals in ${PCA_dir}/Refined_Individuals.list
# add prefix & suffix
wc=$(wc -l Refined_Individuals.list | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	indiv=$(sed -n ${x}p Refined_Individuals.list)
	echo "/home/sejoslin/projects/DS_history/data/RAD_alignments/${indiv}.sort.proper.rmdup.bam" >> ${pop}.no0000.refined.bamlist
	x=$(( $x + 1 ))
done
 
nInd=$(wc -l ${pop}.no0000.refined.bamlist | awk '{print $1}')
mInd=$((${nInd}/2))


#############################
###  for all generations  ###
#############################

### Calculate covariance matrix from randomly sampling a single read for each site for each individual	 ###
### 	and create a 0 or 1 matrix to calc cov matrix from 						 ###

	angsd -bam ${pop}.no0000.refined.bamlist -out ${pop}_pca.noMinMAF.refined -doMajorMinor 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-12 -GL 1 -doMaf 1 -minInd ${mInd} -doCov 1 -doIBS 1 -doCounts 1

