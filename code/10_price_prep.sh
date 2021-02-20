#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J price
#SBATCH -e 10_price_prep.%j.err
#SBATCH -o 10_price_prep.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem=32G 10_price_prep.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data/id_loci"
price_dir="/home/sejoslin/projects/DS_history/data/id_loci/PRICE"
tag="DS_history"

cd $data_dir

mkdir PRICE PRICE/extendLoci_1
cd PRICE

# move things
cp ~sejoslin/scripts/{RecoverLocusSpecificReads.pl,getLoci.py,extendLoci.sh,format_contigs.sh,cat.sh,select_loci.py} ${price_dir}

# concatenate all R1's and all R2's
echo "Conatenating R1's and R2's"
cd ${data_dir}/raw
cat *_R1.fastq > ${price_dir}/${tag}_R1.fastq 
chmod a=r ${price_dir}/${tag}_R1.fastq

cat *_R2.fastq > ${price_dir}/${tag}_R2.fastq
chmod a=r ${price_dir}/${tag}_R2.fastq

# strip the names of the files
cd ${price_dir}
echo "Stripping the names of files from .loci"
perl ${code_dir}/SimplifyLoci2.pl ../${tag}.loci | grep --no-group-separator -A 1 "_1" > ${tag}.loci.s
chmod a=r ${tag}.loci.s
	# get rid of "_1" -- this is the simplified final (sf) version
echo "Creating final simplified version"
sed 's/_1//' ${tag}.loci.s > ${tag}.loci.sf
chmod a=r ${tag}.loci.sf


# split into 8000 line chunks
split -l 8000 ${tag}.loci.sf ${tag}.loci.sf'_'
echo "Every file but the last should have 8000 lines"
wc -l ${tag}.loci.sf_*

echo "Creating data_list of all output files"
ls -l ${tag}.loci.sf_* > data_list

echo "Please check the number of loci (through looking at" ${tag} "or the tail of the final .loci.sf_a? file) and proceed to the next shell script 11_price_extension.sh"
