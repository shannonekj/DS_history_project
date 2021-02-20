#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J SFSpara20
#SBATCH -e 14_getFoldSFS_wParalogs.%j.err
#SBATCH -o 14_getFoldSFS_wParalogs.%j.out
#SBATCH -c 20
#SBATCH --time=24:00:00
#SBATCH --mem=60G
#SBATCH -p high

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

mkdir -p ${para_dir}
mkdir -p ${out_dir}
cd ${para_dir}

### Make bamlist
echo "$(date) : Making bamlist"
ls ${RAD_dir}/*.proper.rmdup.bam > ${pop}.bamlist

### Get reference files
cp ${loci_dir}/DS_history_contigs_250.fasta* .

####################################
###  pull random 20 individuals  ###
###       and record which       ###
####################################

echo "$(date) : Pulling twenty random individuals from ${pop}.bamlist."
cd ${out_dir}
#go to the bamlist and grab a random 20 individuals to use, then make a new bamlist in a separate file
shuf -n 20 ../${pop}.bamlist > ${pop}.rand20.bamlist
echo "They are:"
cat ${pop}.rand20.bamlist


###################
###   get sfs   ###
###################

samtools faidx ../${ref}
sleep 1m
touch ../${ref}.fai

module load angsd
angsd -bam ${pop}.rand20.bamlist -out ${pop}_wPara.rand20 -anc ../${ref} -GL 2 -fold 1 -doSaf 1 -minMapQ 10 -minQ 20
echo "$(date) : Generating folded site frequency spectrum." 
realSFS ${pop}_wPara.saf.idx -maxIter 100 > ${pop}.rand20.sfs
echo "$(date) : plotting SFS."
~/scripts/plotSFS.R ${pop}_wPara.rand20.sfs



