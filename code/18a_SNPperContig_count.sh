#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J snpPcon
#SBATCH -e 18a_SNPperContig_count.%j.err
#SBATCH -o 18a_SNPperContig_count.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-00:00:00
#SBATCH --mem=60G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES
# This script will count the SNPs per contig for all the years combined (1993-2016).


# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
snp_dir="${para_dir}/results_snp"
PARA_dir="${para_dir}/results_paralogs"
ref="${para_dir}/DS_history_contigs_250.fasta"
out_dir="${para_dir}/results_snp_per_contig"


mkdir -p ${out_dir}
cd ${out_dir}

# copy and sort original SNP file
cp ${snp_dir}/${pop}.snp.pos .
sort ${pop}.snp.pos > ${pop}.snp.pos.sorted

echo "This file contains information regarding the SNPs per contig before filtering paralogs (see *.wParalogs.snp.count) and after filtering paralogs (see *noParalogs.snp.count)." > README
echo "The files are:" >> README


######################
###    get snps    ###
###   per contig   ###
######################

### With paralogs

para_stat="wParalogs"
# generate list of loci to look into
cut -f 1 ${snp_dir}/${pop}.snp.pos | uniq - > ${out_dir}/${pop}.${para_stat}.snp.loci
echo "	${pop}.${para_stat}.snp.loci contains all loci pulled from ${para_dir}/results_snp/${pop}.snp.pos" >> README

# count SNPs/loci
n=$(wc -l ${out_dir}/${pop}.${para_stat}.snp.loci | awk '{print $1}')
echo Counting SNPs per contig for ${n} SNPs
x=1
echo Starting with x at $x
while [ $x -le $n ]
do
	locus=$(sed -n ${x}p ${out_dir}/${pop}.${para_stat}.snp.loci)
	snp_count=$(grep -c ${locus} ${snp_dir}/${pop}.snp.pos)
	echo "${locus} ${snp_count}" >> ${out_dir}/${pop}.${para_stat}.snp.count
	x=$(( $x + 1 ))
done


### Without paralogs

# This will look at only the contigs that were not ID'd to be paralogs using:
#	 a random 20 individuals
#		(located at /home/sejoslin/projects/DS_history/data/paralog_id/results_SFS_unfold_wParalogs/DS_history.rand20.bamlist)
#		results found here: /home/sejoslin/projects/DS_history/data/paralog_id/results_paralogs/
#		with both a Bonferroni cutoff (29) and a conservative cutoff (10)


## Bonferroni cutoff
para_stat="noParalogs"
cutoff="29"

# generate a list of all loci that are not paralogs and are polymorphic
awk '{print $1}' ${snp_dir}/${pop}.snp.pos | grep -v -f ${PARA_dir}/${pop}.rand20.same.paralogs.${cutoff}.list | uniq > ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.SNPsPerContig.list
echo " *.SNPsPerContig.list = list of loci that are not paralogs but are polymorphic with SNPs to be counted (will not include all contigs)" >> README

# generate list of loci for future use
sed 's/://g' ${PARA_dir}/${pop}.rand20.same.${cutoff}.loci  > ${pop}.rand20.same.${para_stat}.${cutoff}.snp.loci
echo "	*.snp.loci = list of loci with different paralog filtration cutoffs" >> README

# count SNPs/loci
n=$(wc -l ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.snp.loci | awk '{print $1}')
echo Counting SNPs per contig for $n SNPs
x=1
echo Starting with x at $x
while [ $x -le $n ]
do
        locus=$(sed -n ${x}p ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.SNPsPerContig.list)
        echo Retrieving counts for $locus
	snp_count=$(grep -c ${locus} ${snp_dir}/${pop}.snp.pos)
	echo "${locus} ${snp_count}" >> ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.snp.count
        x=$(( $x + 1 ))
done
echo "	*.snp.count = loci from *snp.loci with a count of the snps_per_locus" >> README


## Conservative cutoff
para_stat="noParalogs"
cutoff="10"

# generate a list of all loci that are not paralogs and are polymorphic
awk '{print $1}' ${snp_dir}/${pop}.snp.pos | grep -v -f ${PARA_dir}/${pop}.rand20.same.paralogs.${cutoff}.list | uniq > ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.SNPsPerContig.list

# generate list of loci for future use
sed 's/://g' ${PARA_dir}/${pop}.rand20.same.${cutoff}.loci  > ${pop}.rand20.same.${para_stat}.${cutoff}.snp.loci

# count SNPs/loci
n=$(wc -l ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.snp.loci | awk '{print $1}')
echo Counting SNPs per contig for $n SNPs
x=1
echo Starting with x at $x
while [ $x -le $n ]
do
        locus=$(sed -n ${x}p ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.SNPsPerContig.list)
        echo Retrieving counts for $locus
        snp_count=$(grep -c ${locus} ${snp_dir}/${pop}.snp.pos)
        echo "${locus} ${snp_count}" >> ${out_dir}/${pop}.rand20.same.${para_stat}.${cutoff}.snp.count
        x=$(( $x + 1 ))
done

# by year
#cp ../year.list . 
#infile="year.list"
#
#n=$(wc -l $infile | awk '{print $1}')
#x=1
#while [ $x -le $n ]
#do
#	year=$(sed -n ${x}p $infile)
#n=$(wc -l $infile | awk '{print $1}')
#x=1
#while [ $x -le $n ]
#do
#	year=$(sed -n ${x}p $infile)
#        cut -f 1 ${snp_dir}/Ht_${year}.snp.pos | uniq - > ${out_dir}/Ht_${year}.snp.loci
#
#        m=$(wc -l ${out_dir}/Ht_${year}.snp.loci | awk '{print $1}')
#        y=1
#        while [ $y -le $m ]
#        do
#                locus=$(sed -n ${y}p ${out_dir}/Ht_${year}.snp.loci)
#                snp_count=$(grep -c ${locus} ${snp_dir}/Ht_${year}.snp.pos)
#                echo "${locus}  ${snp_count}" >> ${out_dir}/Ht_${year}.snp.count
#                y=$(( $y + 1 ))
#        done
