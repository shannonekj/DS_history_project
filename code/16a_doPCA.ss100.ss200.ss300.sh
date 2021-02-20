#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J doPCA
#SBATCH -e 16a_doPCA.ss100.ss200.ss300.%j.err
#SBATCH -o 16a_doPCA.ss100.ss200.ss300.%j.out
#SBATCH -c 20
#SBATCH --time=20:00:00
#SBATCH --mem=60G

set -e # exits upon failing command
set -v # verbose -- all lines

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="${data_dir}/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
PCA_dir="${data_dir}/RAD_PCA"

# need to use a more recent version of angsd so using from home dir
#module load angsd

# Make list of all bam files
touch ${PCA_dir}/${pop}.sort.proper.rmdup.bamlist
touch ${PCA_dir}/${pop}.sort.proper.rmdup.ss100.bamlist
touch ${PCA_dir}/${pop}.sort.proper.rmdup.ss200.bamlist
touch ${PCA_dir}/${pop}.sort.proper.rmdup.ss300.bamlist

cd ${RAD_dir}

for i in *.sort.proper.rmdup.bam
do
	echo $i >> ${PCA_dir}/${pop}.sort.proper.rmdup.bamlist
done

# make lists of files with over 100k, 200k and 300k reads.
cd ${PCA_dir}

wc=$(wc -l ${PCA_dir}/${pop}.sort.proper.rmdup.bamlist | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	string="sed -n ${x}p ${pop}.sort.proper.rmdup.bamlist"
	str=$($string)
	var=$(echo $str | awk -F"\t" '{print $1}')
	set -- $var
	c1=$1
	count=$(samtools view -c ${RAD_dir}/${c1})

	if [ 100000 -le ${count} ]
	then
		echo ${RAD_dir}/${c1} >> ${PCA_dir}/${pop}.sort.proper.rmdup.ss100.bamlist
		echo "${c1} has greater than 100,000 reads!"
	fi


	if [ 200000 -le ${count} ]
	then 
		echo ${RAD_dir}/${c1} >> ${PCA_dir}/${pop}.sort.proper.rmdup.ss200.bamlist
		echo "${c1} has greater than 200,000 reads!"
	fi


	if [ 300000 -le ${count} ]
	then
		echo ${RAD_dir}/${c1} >> ${PCA_dir}/${pop}.sort.proper.rmdup.ss300.bamlist
		echo "${c1} has greater than 300,000 reads!"
	fi

x=$(( $x + 1 ))

done



# create PCA for each 

for i in ${pop}.sort.proper.rmdup.ss?00.bamlist
do
	nInd=$(wc -l $i | awk '{print $1}')
	mInd=$((${nInd}/2))
	readCount=$(echo $i | cut -d. -f5)
	echo Creating PCA files for ${readCount} $(date)
	        echo "#!/bin/bash" > ${readCount}.sh
		echo "#SBATCH -e ${readCount}.%j.err" >> ${readCount}.sh
                echo "#SBATCH -o ${readCount}.%j.out" >> ${readCount}.sh
                echo "#SBATCH -t 2880" >> ${readCount}.sh
                echo "#SBATCH --mem=60G" >> ${readCount}.sh
                echo "set -e" >> ${readCount}.sh
                echo "set -v" >> ${readCount}.sh
		echo "angsd -bam $i -out ${readCount}_pca -doMajorMinor 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-12 -GL 1 -doMaf 1 -minInd ${mInd} -minMaf 0.05 -doCov 1 -doIBS 1 -doCounts 1" >> ${readCount}.sh 
	
	sbatch -J PCA_${readCount} ${readCount}.sh
done








## Need to remove year 0 when plotting
