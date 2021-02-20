#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J SFSplot20
#SBATCH -e 16_plotSFS_wParalogs.%j.err
#SBATCH -o 16_plotSFS_wParalogs.%j.out
#SBATCH -c 20
#SBATCH --time=24:00:00
#SBATCH --mem=60G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
# This script will plot folded 1d site frequency spectrum for a random 20 individuals and the ML estimate of the sfs using the EM algorithm for each year. 

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="${data_dir}/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
para_dir="${data_dir}/paralog_id"
out_dir="${para_dir}/results_SFS_fold_wParalogs"

ref="${pop}_contigs_250.fasta"

# run script with
#	sbatch 16_plotSFS_wParalogs.sh


####################
###   plot sfs   ###
####################

echo "$(date) : Generating folded site frequency spectrum." 
realSFS ${pop}_wPara.saf.idx -maxIter 100 > ${pop}.sfs
echo "$(date) : plotting SFS."
~/scripts/plotSFS.R ${pop}_wPara.sfs



