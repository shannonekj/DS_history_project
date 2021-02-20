#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J listParS
#SBATCH -e 17c_filterParalog_listParalogs.rand20.both.%j.err
#SBATCH -o 17c_filterParalog_listParalogs.rand20.both.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=24:00:00

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES
### Get a list of paralogous loci using different stringency cutoffs ###
# 	This script will use the same random 20 individuals that were used to generate the unfolded SFS located in /home/sejoslin/projects/DS_history/data/paralog_id/results_SFS_unfold_wParalogs

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

################################
###  Extract different loci  ###
###  with different p-value  ###
###   cutoffs for paralogs   ###
################################

## BONFERRONI
# Calculate a p-value cutoff from Bonferroni corrected p-value (P=0.05/#SNPs) then find chi-squared valued using the following website:
# https://www.di-mgt.com.au/chisquare-calculator.html

## Same 20
cutoff="29"
echo "Making a list of paralogs $(date)"
awk '($5 > '29')' results_paralogs/${pop}.rand20.same.paralogs | cut -c1-7 | uniq > results_paralogs/${pop}.rand20.same.${cutoff}.paralogs.list
echo "Making a list of the loci with paralogs $(date)"
grep '>' ${ref} | cut -c2- | grep -v -f results_paralogs/${pop}.rand20.same.${cutoff}.paralogs.list | sed 's/$/:/' > ${pop}.rand20.same.${cutoff}.loci

## Different 20
#echo "Making a list of paralogs $(date)"
#awk '($5 > '29')' results_paralogs/${pop}.rand20.diff.paralogs | cut -c1-7 | uniq > results_paralogs/${pop}.rand20.diff.${cutoff}.paralogs.list
#echo "Making a list of the loci with paralogs $(date)"
#grep '>' ${ref} | cut -c2- | grep -v -f results_paralogs/${pop}.rand20.diff.${cutoff}.paralogs.list | sed 's/$/:/' > ${pop}.rand20.same.29.loci


## CONSERVATIVE
cutoff="10"
echo "Making a list of paralogs $(date)"
awk '($5 > '10')' results_paralogs/${pop}.rand20.same.paralogs | cut -c1-7 | uniq > results_paralogs/${pop}.rand20.same.${cutoff}.paralogs.list
echo "Making a list of the loci with paralogs $(date)"
grep '>' ${ref} | cut -c2- | grep -v -f results_paralogs/${pop}.rand20.same.${cutoff}.paralogs.list | sed 's/$/:/' > ${pop}.rand20.same.${cutoff}.loci



## Different 20
#echo "Making a list of paralogs $(date)"
#awk '($5 > '10')' results_paralogs/${pop}.rand20.diff.paralogs | cut -c1-7 | uniq > results_paralogs/${pop}.rand20.diff.${cutoff}.paralogs.list
#echo "Making a list of the loci with paralogs $(date)"
#grep '>' ${ref} | cut -c2- | grep -v -f results_paralogs/${pop}.rand20.diff.${cutoff}.paralogs.list | sed 's/$/:/' > ${pop}.rand20.same.29.loci



