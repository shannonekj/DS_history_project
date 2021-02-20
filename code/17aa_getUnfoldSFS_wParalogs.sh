#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J SFSpara20
#SBATCH -e 17aa_getUnfoldSFS_wParalogs.%j.err
#SBATCH -o 17aa_getUnfoldSFS_wParalogs.%j.out
#SBATCH -c 20
#SBATCH --time=24:00:00
#SBATCH --mem=60G
#SBATCH -p high

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
# This script will plot unfolded 1d site frequency spectrum for a random 20 individuals and the ML estimate of the sfs using the EM algorithm for each year. 

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="${data_dir}/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
para_dir="${data_dir}/paralog_id"
out_dir="${para_dir}/results_SFS_unfold_wParalogs"

ref="${pop}_contigs_250.fasta"

mkdir -p ${para_dir}
mkdir -p ${out_dir}
cd ${para_dir}

### Make bamlist
# ALREADY COMPLETED echo "$(date) : Making bamlist"
# ALREADY COMPLETED ls ${RAD_dir}/*.proper.rmdup.bam > ${pop}.bamlist

### Get reference files
# ALREADY COMPLETED #cp ${loci_dir}/DS_history_contigs_250.fasta* .
# ALREADY COMPLETED # chmod a=r ${loci_dir}/DS_history_contigs_250.fasta

####################################
###  pull random 20 individuals  ###
###       and record which       ###
####################################

# ALREADY COMPLETED echo "$(date) : Pulling twenty random individuals from ${pop}.bamlist."
cd ${out_dir}
##go to the bamlist and grab a random 20 individuals to use, then make a new bamlist in a separate file
# ALREADY COMPLETED shuf -n 20 ../${pop}.bamlist > ${pop}.rand20.bamlist
# ALREADY COMPLETED echo "They are:"
# ALREADY COMPLETED cat ${pop}.rand20.bamlist

cp ../old_results_SFS_unfold_wParalogs/${pop}.rand20.bamlist .

###################
###   get sfs   ###
###################

# ALREADY COMPLETED #echo "Indexing reference."
# ALREADY COMPLETED #samtools faidx ../${ref}
# ALREADY COMPLETED #sleep 1m
# ALREADY COMPLETED #touch ../${ref}.fai

echo "Creating site allele frequency likelihood based on genotype likelihoods assuming HWE."
module load angsd
angsd -bam ${pop}.rand20.bamlist -out ${pop}_wPara.rand20 -anc ../${ref} -GL 1 -doSaf 1 -minMapQ 20 -minQ 20 -minInd 10
echo "$(date) : Generating unfolded site frequency spectrum." 
realSFS ${pop}_wPara.rand20.saf.idx -maxIter 100 > ${pop}_wPara.rand20.sfs
echo "$(date) : plotting SFS."
~/scripts/plotSFS.R ${pop}_wPara.rand20.sfs



