#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J EXTEND3
#SBATCH -e 11_price_extension3.%j.err
#SBATCH -o 11_price_extension3.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem=32G 11_price_extension3.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data/id_loci"
price_dir="/home/sejoslin/projects/DS_history/data/id_loci/PRICE"
extend_dir="/home/sejoslin/projects/DS_history/data/id_loci/PRICE/extendLoci_1" # note only one directory because on aa to ai was used -- will need more if you have a Loci_aa and Loci_bb file
tag="DS_history"

##############################

# you should have moved scripts we will use:
#	format_contigs.sh
#	RecoverLocusSpecificReads.sh
#	run.sh
#	run2.sh
#	run_extendloci.sh	
#	RecoverLocusSpecificReads.pl
#	getLoci2.py
# and create fasta.list files and loci.list files they should refer to each of the aa-??
# format FASTA.LIST 
#	../OVITY.loci.fasta_ba
#	../OVITY.loci.fasta_bb
#	../OVITY.loci.fasta_bc
#	further, if we "head ../OVITY.loci.fasta_ba"
#		>R104001
#		ATGGTTGGAATGCAGGAGCAACAACGGGGAAGGCCCACTGGCTAAGTATAATGCTACTTCGCAAATAGCCTAATGTGTTT
#		>R104002
#		ACGCGCTTTGGGGGTATGTGTGACGTTATTGCTGAGTTCTCGCAAATAACAGGTTTATATCCTAGGGGAATGTAATGTAC
# format for LOCI.LIST
#	../OVITY.loci.list_ba
#	../OVITY.loci.list_bb
#	../OVITY.loci.list_bc
#	further if we "head ../OVITY.loci.list_ba"
#		R104001
#		R104002
#		R104003


###################
### EXTEND LOCI ###
###################

cd $extend_dir
# create template & fastq's (this creates a 1. template 2. forward reads 3. reverse reads pertaining to loci)
##sh RecoverLocusSpecificReads.sh fasta.list DS_history

# extend loci using three files (results in file with extension *sh run.sh loci.list)
# uses file:
#	run_extendloci.sh
##sh run.sh loci.list

# re-format contigs
# uses file:
#	format_contigs.sh
sh run2.sh loci.list

### after this runs concatencate all files with || cat *_contig.fasta > ../DS_history_contigs.fasta
