#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J selectLoci
#SBATCH -e 12_select_loci.%j.err
#SBATCH -o 12_select_loci.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem=32G 12_select_loci.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data/id_loci"
price_dir="/home/sejoslin/projects/DS_history/data/id_loci/PRICE"
extend_dir="/home/sejoslin/projects/DS_history/data/id_loci/PRICE/extendLoci_1" # note only one directory because on aa to ai was used -- will need more if you have a Loci_aa and Loci_bb file
tag="DS_history"

# make sure you concatenated all files from extendLoci_? with || cat *_contig.fasta > ../${tag}_contigs.fasta

##################
## Select Loci ### 
##################

cd $price_dir

cp ~sejoslin/scripts/select_loci.py .

echo "selecting loci over 250bp"
date
python select_loci.py ${tag}_contigs.fasta 250 
echo "completed at"
date
