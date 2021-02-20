#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J para20d
#SBATCH -e 17b_filterParalog_getParalogs.rand20.diff.%j.err
#SBATCH -o 17b_filterParalog_getParalogs.rand20.diff.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-24:00:00

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES
### Calculate paralog probabilities and get a list of paralogous loci  ###
# 	This script will use a different random 20 individuals than were used to generate the unfolded SFS located in 

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
RAD_dir="${data_dir}/RAD_alignments"
para_dir="${data_dir}/paralog_id"
uSFS_dir="${para_dir}/results_SFS_unfold_wParalogs"
ref="${para_dir}/DS_history_contigs_250.fasta"
out_dir="results_paralogs"


cd ${para_dir}
mkdir -p ${out_dir}

###############################
###    calculate paralog    ###
###     probabilities       ###
###   and filter paralogs   ###
###############################

#go to the bamlist and grab a random 20 individuals to use, then make a new bamlist in a separate file
shuf -n 20 ${pop}.bamlist > ${out_dir}/${pop}.rand20.diff.bamlist
echo "They are:"
cat ${out_dir}/${pop}.rand20.diff.bamlist

# for all years at once
echo "Counting depth $(date)"
samtools mpileup -b ${out_dir}/${pop}.rand20.diff.bamlist -l results_snp/${pop}.snp.pos -f ${ref} > results_paralogs/${pop}.rand20.diff.depth

echo "Calculating paralog probabilities $(date)"
~/bin/ngsParalog/ngsParalog calcLR -infile results_paralogs/${pop}.rand20.diff.depth > results_paralogs/${pop}.rand20.diff.paralogs

# Calculate a p-value cutoff from Bonferroni corrected p-value (P=0.05/#SNPs) then find chi-$
# https://www.di-mgt.com.au/chisquare-calculator.html
echo "Making a list of paralogs $(date)"
cutoff="29"
awk '($5 > '${cutoffs}')' results_paralogs/${pop}.rand20.diff.paralogs | cut -c1-7 | uniq > results_paralogs/${pop}.rand20.diff.paralogs.${cutoff}.list

echo "Making a list of the loci with paralogs $(date)"
grep '>' ${ref} | cut -c2- | grep -v -f results_paralogs/${pop}.rand20.diff.paralogs.${cutoff}.list | sed 's/$/:/' > ${pop}.rand20.diff.${cutoff}.loci


