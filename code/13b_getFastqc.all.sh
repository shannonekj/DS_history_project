#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J theta
#SBATCH -e 13b_getFastqc.all.%j.err
#SBATCH -o 13b_getFastqc.all.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-00:00:00
#SBATCH --mem=60G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES
# This script will calculate theta statistics by year.
#	Filters: 	paralogs removed
#			MAF < 0.05 removed
#			SNP p-value > 1e-06 removed
#	Variable Filts:	minInd (0.5, 0.8. 0.95)
#			postCutoff
#	Statistics:	Theta

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
aln_dir="${data_dir}/RAD_alignments"
out_dir="${data_dir}/fastqc"


mkdir -p ${out_dir}
cd ${out_dir}
mkdir -p SFS

touch README

### make bamlist for each year (1993-2016)
seq 2016 2016 > year.list
# by year
infile="year.list"
# grab refined list
refined="Refined_Individuals"
cp ${PCA_dir}/${refined}.list ${out_dir}/.
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
	ls -alh Ht*${year}*.rmdup.bam | awk '{print $9}' > ${out_dir}/Ht_${year}_all.bamlist
	cd ${out_dir}
	# grab files that are in both refined and Ht_${year}_all
	comm -12 <(sort DS_history.no0000.refined.bamlist) <(sort Ht_${year}_all.bamlist)
	# create script to make SFS for each year with the top 100 individuals from that year
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
		echo "lines=$(wc -l Ht_${year}_all.bamlist | awk '{print $1}')" >> Ht_${year}.thetas.sh
		echo "y=1" >> Ht_${year}.thetas.sh
		echo "while [ \$y -le \$lines ]" >> Ht_${year}.thetas.sh
		echo "do" >> Ht_${year}.thetas.sh
			echo "	STRING=\"sed -n \${y}p Ht_${year}_all.bamlist\"" >> Ht_${year}.thetas.sh
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
		echo "printing theta stats!" >> Ht_${year}.thetas.sh
		echo "thetaStat print Ht_${year}.thetas.idx | gzip > Ht_${year}.thetas.readable.gz" >> Ht_${year}.thetas.sh
		echo "thetaStat do_stat Ht_${year}.thetas.idx" >> Ht_${year}.thetas.sh

#submit job
# partition into differnt partitions with comparison operators
if [[ ${year} -lt 2001 ]]
	then
	sbatch -p bigmemh Ht_${year}.thetas.sh
	elif [[ ${year} -ge 2001 && ${year} -le 2008 ]]
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



