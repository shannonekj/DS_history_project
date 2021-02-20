#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J theta
#SBATCH -e 19a_popGen_thetas.refined.ss500.%j.err
#SBATCH -o 19a_popGen_thetas.refined.ss500.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-00:00:00
#SBATCH --mem=60G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES
# This script will calculate theta statistics for 20 individuals with over 500k alignments for each year.
#	Filters: 	paralogs removed
#	Statistics:	Theta

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
aln_dir="${data_dir}/RAD_alignments"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
snp_dir="${para_dir}/results_snp_per_contig"
out_dir="${data_dir}/popgen_theta_ss500"

ref="${para_dir}/DS_history_contigs_250.fasta"

# use the 0.921 verison of angsd

mkdir -p ${out_dir}
cd ${out_dir}
mkdir -p SFS

touch README

### make bamlist for each year (1993-2016)
seq 1993 2016 > year.list
# take out the no-data years
sed -i '/1994/d' year.list
sed -i '/2001/d' year.list
sed -i '/2003/d' year.list
sed -i '/2005/d' year.list
echo "This file contains files for estimating theta (Watterson's and Pi) for 20 random samples from (1993-2016) with over 500k alignments. Analysis was restricted to sites that were not deemed paralogs with a Bonferroni Cutoff" >> README
echo "The files contained in this directory are:" >> README
echo "    year.list = a list of all the years to estimate thera for. Note: 1994, 2001, 2003, and 2005 were all excluded because we do not have or have insufficient individuals from these years." >> README
# by year
infile="year.list"
echo "    year.list = list with all individuals for each year" >> README
# grab refined list
refined="Refined_Individuals"
cp ${PCA_dir}/${refined}.list ${out_dir}/.
echo "   ${refined}.list = copied from ${PCA_dir} these are the names of individuals that are believed not to be misclassified as of $date" >> README
# extend refined list into bamlist
wc=$(wc -l ${refined}.list | awk '{print $1}')
x=1
while [ ${x} -le ${wc} ]
do
	indiv=$(sed -n ${x}p ${refined}.list)
	echo "${indiv}.sort.proper.rmdup.bam" >> ${refined}.bamlist
	x=$(( $x + 1 ))
done



## Create Theta Scripts for each year
# FIRST RUN = minInd 0.5
n=$(wc -l $infile | awk '{print $1}')
x=1
while [ $x -le $n ]
do
	year=$(sed -n ${x}p $infile)
	# generate bamlist for each year
	cd ${aln_dir} 
	ls -alh Ht*${year}*.rmdup.bam | awk '{print $9}' > ${out_dir}/Ht_${year}.all.bamlist
	# grab master list of refined inidividuals to be analyzed
	cp ${PCA_dir}/DS_history.no0000.refined.bamlist ${out_dir}/DS_history.no0000.refined.bamlist
	cd ${out_dir}
	# grab files that are in both refined individuals list and Ht_${year}.all
	comm -12 <(cut -d/ -f8 DS_history.no0000.refined.bamlist | sort) <(sort Ht_${year}.all.bamlist) > Ht_${year}.refined.bamlist
	# create script to make SFS for each year with the top 100 individuals from that year excluding outliers
		echo "#!/bin/bash" >> Ht_${year}.thetas.sh
                echo "#SBATCH -e Ht_${year}.thetas.err" >> Ht_${year}.thetas.sh
                echo "#SBATCH -o Ht_${year}.thetas.out" >> Ht_${year}.thetas.sh
                echo "#SBATCH --time=2-10:00:00" >> Ht_${year}.thetas.sh
                echo "#SBATCH --mem=60G" >> Ht_${year}.thetas.sh
		echo "#SBATCH -c 24" >> Ht_${year}.thetas.sh
		echo "#SBATCH -J SFS${year}" >> Ht_${year}.thetas.sh
                echo "set -e" >> Ht_${year}.thetas.sh
                echo "set -v" >> Ht_${year}.thetas.sh
                echo "" >> Ht_${year}.thetas.sh
                echo "cd ${out_dir}" >> Ht_${year}.thetas.sh
		echo "" >> Ht_${year}.thetas.sh
	# first take make a list of individuals sorted by read count
		echo "lines=$(wc -l Ht_${year}.refined.bamlist | awk '{print $1}')" >> Ht_${year}.thetas.sh
		echo "y=1" >> Ht_${year}.thetas.sh
		echo "while [ \$y -le \$lines ]" >> Ht_${year}.thetas.sh
		echo "do" >> Ht_${year}.thetas.sh
			echo "	STRING=\"sed -n \${y}p Ht_${year}.refined.bamlist\"" >> Ht_${year}.thetas.sh
			echo "	STR=\$(\$STRING)" >> Ht_${year}.thetas.sh
			echo "	VAR=\$(echo \$STR | awk -F\"\t\" '{print \$1}')" >> Ht_${year}.thetas.sh
			echo "	set -- \$VAR" >> Ht_${year}.thetas.sh
			echo "	C1=\$1" >> Ht_${year}.thetas.sh
			echo "	COUNT=\$(samtools view -c ${aln_dir}/\${C1})" >> Ht_${year}.thetas.sh
			echo "	echo ${aln_dir}/\${C1} \${COUNT} >> Ht_${year}.ReadCount.list" >> Ht_${year}.thetas.sh
			echo "	y=\$(( \$y + 1 ))" >> Ht_${year}.thetas.sh
		echo "done" >> Ht_${year}.thetas.sh
	# use this list to grab up to the best 100 individuals
		echo "sort -k 2 -r -n Ht_${year}.ReadCount.list >> Ht_${year}.ReadCount.Sorted.list" >> Ht_${year}.thetas.sh 
		echo "head -100 Ht_${year}.ReadCount.Sorted.list | awk '{print \$1}' >> Ht_${year}.ReadCount.Sorted.best100.bamlist" >> Ht_${year}.thetas.sh
	# restrict SFS for each year to sites that are not paralogs
	# generate SFS for each year (w/o paralogs)
		echo "echo \$(date) Calculating site allele frequency likelihoods to create SFS." >> Ht_${year}.thetas.sh
		echo "nInd=\$(wc -l ${out_dir}/Ht_${year}.ReadCount.Sorted.best100.bamlist | awk '{print \$1}')" >> Ht_${year}.thetas.sh
		echo "mInd=\$((\${nInd}/2))" >> Ht_${year}.thetas.sh
		echo "module load bio" >> Ht_${year}.thetas.sh
		echo "angsd --version" >> Ht_${year}.thetas.sh
# need to have MAF and SNP p-value cutoff to generate list of usable SNPs (idiot)
		echo "angsd -bam ${out_dir}/Ht_${year}.ReadCount.Sorted.best100.bamlist -ref ${ref} -anc ${ref} -rf ${PARA_dir}/${pop}.rand20.same.29.loci -out ${out_dir}/SFS/Ht_${year} -GL 1 -doSaf 1 -minMapQ 20 -minQ 20 -P 24 -minInd \${mInd}" >> Ht_${year}.thetas.sh
		echo "echo Done calculating." >> Ht_${year}.thetas.sh
		echo "echo \$(date) Generating unfolded site frequency spectrum with a cutoff of 29" >> Ht_${year}.thetas.sh
		echo "realSFS ${out_dir}/SFS/Ht_${year}.saf.idx -maxIter 100 -P 20 > ${out_dir}/SFS/Ht_${year}.sfs" >> Ht_${year}.thetas.sh
		echo "echo Done generating uSFS and onto plotting!" >> Ht_${year}.thetas.sh
		echo "echo \$(date) : plotting SFS." >> Ht_${year}.thetas.sh
		echo "/home/sejoslin/scripts/plotSFS.R ${out_dir}/SFS/Ht_${year}.sfs" >> Ht_${year}.thetas.sh 
	# then plug that in to calculate the per site thetas
	# calculate theta for each site
		echo "angsd -bam ${out_dir}/Ht_${year}.ReadCount.Sorted.best100.bamlist -out ${out_dir}/Ht_${year} -doThetas 1 -doSaf 1 -pest ${out_dir}/SFS/Ht_${year}.sfs -anc ${ref} -GL 1 -minMapQ 20 -minQ 20 -P 24 -minInd \${mInd} -rf ${PARA_dir}/${pop}.rand20.same.29.loci" >> Ht_${year}.thetas.sh
		# print stats!
		echo "echo printing theta stats!" >> Ht_${year}.thetas.sh
		echo "thetaStat print Ht_${year}.thetas.idx | gzip > Ht_${year}.thetas.readable.gz" >> Ht_${year}.thetas.sh
		echo "thetaStat do_stat Ht_${year}.thetas.idx" >> Ht_${year}.thetas.sh

#submit job
# partition into differnt partitions with comparison operators
if [[ ${year} -lt 2000 ]]
	then
	sbatch -p bigmemh Ht_${year}.thetas.sh
	elif [[ ${year} -ge 2000 && ${year} -le 2008 ]]
		then
		sbatch -p bigmemm Ht_${year}.thetas.sh	
		elif [[ ${year} -gt 2008 ]]
			then 
			sbatch -p high Ht_${year}.thetas.sh
			else
				echo ${year} "Not a valid year!"
fi 

	x=$(( $x + 1 ))
done

# README information
echo "    .bamlist = short bamlist of all individuals for a particular year" >> README
echo "    .ReadCount.list = global path to bam files with the number of read counts for each individual" >> README
echo "    .ReadCount.Sorted.list = sorted .ReadCount.list by read count" >> README
echo "    .ReadCount.Sorted.best100.bamlist = global path to up to the top 100 individual's bam files" >> README
echo "    .thetas.sh = script to run estimation of thetas" >> README
echo "    .thetas.gz = output from doThetas. Contains LENGTH_CHR, CHR, NSITES, NCHR, POSI, Watterson's, Pi, FuLi, FayH, L" >> README
echo "    .thetas.idx = Small uncompressed binary file that contains chr, number of sites, number of chromosomes and the offset into the main data file contain the theta estimates." >> README
echo "    .thetas.readable.gz = gzipped readable output of thetas (I believe this is log scaled)" >> README
echo "    .pestPG = 14 column file (tab separated) with information on region, reference name and five estimators of theta, final column is the effective numb of sites with data in the window" >> README
echo "" >> README
echo "The SFS file contains an unfolded site frequecy spectrum for up to the top 100 individuals for each year." >> README		


