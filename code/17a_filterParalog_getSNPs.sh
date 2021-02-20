#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J get_snps
#SBATCH -e 17a_filterParalog_getSNPs.%j.err
#SBATCH -o 17a_filterParalog_getSNPs.%j.out
#SBATCH -c 20
#SBATCH -p bigmemh
#SBATCH --time=3-00:00:00
#SBATCH --mem=256G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
#	Get snps to find paralogs.

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
RAD_dir="${data_dir}/RAD_alignments"
orig_ref="${data_dir}/id_loci/PRICE/DS_history_contigs_250.fasta"
ref="${para_dir}/DS_history_contigs_250.fasta"


############################
###   make directories   ###
############################

#mkdir -p ${para_dir}
cd ${para_dir}
#mkdir -p results_snp

# make a file with all the years
#seq 1993 2016 > year.list
#sed -i '/1994/d' year.list
#sed -i '/2001/d' year.list
#sed -i '/2003/d' year.list
#sed -i '/2005/d' year.list

# copy reference fasta and index
#module load bwa
#bwa index -a is ${ref}

#module load samtools
#samtools faidx ${ref}

#sleep 1m

#touch ${ref}.fai

####################
###   get snps   ###
####################

# get bamlist
#ls ${RAD_dir}/*.proper.rmdup.bam > ${pop}.bamlist

#use newest version of angsd
module load bio
angsd --version

# get genotype likelihoods
nInd=$(wc -l ${pop}.bamlist | awk '{print $1}')
mInd=$((${nInd}/2)) 
angsd -bam ${pop}.bamlist -out results_snp/${pop}.pval.minMAF -ref ${ref} -GL 1 -doMajorMinor 1 -doMaf 1 -minMapQ 20 -minQ 20 -minInd ${mInd} -SNP_pval 1e-6 -minMAF 0.05
gunzip results_snp/${pop}.pval.minMAF*.gz
cut -d$'\t' -f1-2 results_snp/${pop}.pval.minMAF.mafs | sed 1d > results_snp/${pop}.pval.minMAF.snp.pos


