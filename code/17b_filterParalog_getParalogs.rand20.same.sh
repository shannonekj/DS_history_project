#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J para20s
#SBATCH -e 17b_filterParalog_getParalogs.rand20.same.%j.err
#SBATCH -o 17b_filterParalog_getParalogs.rand20.same.%j.out
#SBATCH -c 20
#SBATCH -p bigmemh
#SBATCH --time=1-24:00:00

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES
### Calculate paralog probabilities and get a list of paralogous loci  ###
# 	This script will use the same random 20 individuals that were used to generate the unfolded SFS located in 

## set up directories
# global
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
RAD_dir="${data_dir}/RAD_alignments"
para_dir="${data_dir}/paralog_id"
uSFS_dir="${para_dir}/results_SFS_unfold_wParalogs"
ref="${para_dir}/DS_history_contigs_250.fasta"

# local
snp_dir="results_snp_noPval"
out_dir="results_paralogs"

cd ${para_dir}
mkdir -p ${out_dir}

touch ${out_dir}/README
echo "This directory contains files used to find paralogs from a random set of 20 individuals found at ${uSFS_dir} Important information includes using a minimum individual cutoff for identifying SNPs (low coverage RAD sequences are less likely to be erroneously identified as paralogs." >> ${out_dir}/README
echo "Generated on $(date)." >> ${out_dir}/README
echo "Files include:" >> ${out_dir}/README


###############################
###    calculate paralog    ###
###     probabilities       ###
###   and filter paralogs   ###
###############################

## CALCULATE ##

echo "Counting depth $(date)"
samtools mpileup -b ${uSFS_dir}/${pop}.rand20.bamlist -l ${snp_dir}/${pop}.snp.pos -f ${ref} > ${out_dir}/${pop}.rand20.same.depth
echo "    .depth = output from mpileup" >> ${out_dir}/README

cd ${out_dir}

echo "Calculating paralog probabilities $(date)"
~/bin/ngsParalog/ngsParalog calcLR -infile ${pop}.rand20.same.depth > ${pop}.rand20.same.paralogs
echo "    .paralogs = persite likelihood ratios of duplication" >> README

### FILTER ###

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



echo "    .xx.list = a list of paralogous loci with various cutoffs (xx)" >> README
echo "    .xx.loci = list of loci that are not paralogs based on different cutoffs" >> README

echo "After this restrict analyses to non-paralogous sites in ANGSD." >> README
