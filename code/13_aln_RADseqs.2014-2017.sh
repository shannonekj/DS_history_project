#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J aln1417
#SBATCH -e 13_aln_RADseqs.2014-2017.%j.err
#SBATCH -o 13_aln_RADseqs.2014-2017.%j.out
#SBATCH -c 20
#SBATCH -n 1
#SBATCH --mem=60G
#SBATCH --time=20:00:00

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution


# set up directories
pop="DS_history"
years="2014-2017"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="${data_dir}/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
out_dir="${RAD_dir}/2014_to_2017"

## NOTE: Need list of all sequence file names in a .list file.

mkdir -p ${out_dir}

####################
###  make .list  ###
####################
cd ${data_dir}
touch RAD_alignments/${pop}.${years}.RADseqID.list

for i in BMAG055
do
	cd $i
	for f in 04_split_wells*.sh
	do 
		tag=$(echo $f | cut -d. -f3)
		echo $tag
		cd $tag
		for file in Ht*_R1.fastq 
		do
			newname=$(basename $file _R1.fastq)
			echo $newname $i/$tag/$newname >> ../../RAD_alignments/2014_to_2017/${pop}.${years}.RADseqID.list
		done
		cd ../
	done
	cd ../
done

#########################
###  index reference  ###
########################

#bwa index ${loci_dir}/${pop}_contigs_250.fasta
ref="${loci_dir}/${pop}_contigs_250.fasta"

#######################
###  align RAD seq  ###
#######################

cd ${out_dir}

wc=$(wc -l ${pop}.${years}.RADseqID.list | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	string="sed -n ${x}p ${pop}.${years}.RADseqID.list"
	str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- $var
        c1=$1
	c2=$2
	
        echo "#!/bin/bash -l" >> aln_${c1}.sh
        echo "#SBATCH -o ${c1}.%j.out" >> aln_${c1}.sh
        echo "#SBATCH -e ${c1}.%j.err" >> aln_${c1}.sh
	echo "#SBATCH --mem=16G" >> aln_${c1}.sh
	echo "#SBATCH -t 10:00:00" >> aln_${c1}.sh
	echo "#SBATCH -J ${c1}" >> aln_${c1}.sh
	echo "" >> aln_${c1}.sh
	echo "echo Now aligning reads \$(date)" >> aln_${c1}.sh
	echo "bwa mem ${ref} ${data_dir}/${c2}_R1.fastq ${data_dir}/${c2}_R2.fastq | samtools view -Sb - | samtools sort - ${c1}.sort" >> aln_${c1}.sh
	echo "echo Now pairing reads \$(date)" >> aln_${c1}.sh
	echo "samtools view -f 0x2 -b ${c1}.sort.bam > ${c1}.sort.proper.bam" >> aln_${c1}.sh
	echo "echo Removing duplicate reads \$(date)" >> aln_${c1}.sh
	echo "samtools rmdup ${c1}.sort.proper.bam ${c1}.sort.proper.rmdup.bam" >> aln_${c1}.sh 
        echo "sleep 2m" >> aln_${c1}.sh
	echo "echo Indexing alignment \$(date)" >> aln_${c1}.sh
        echo "samtools index ${c1}.sort.proper.rmdup.bam ${c1}.sort.proper.rmdup.bam.bai" >> aln_${c1}.sh
        echo "reads=\$(samtools view -c ${c1}.sort.bam)" >> aln_${c1}.sh
        echo "ppalign=\$(samtools view -c ${c1}.sort.proper.bam)" >> aln_${c1}.sh
        echo "rmdup=\$(samtools view -c ${c1}.sort.proper.rmdup.bam)" >> aln_${c1}.sh
        echo "echo \"${c1},\${reads},\${ppalign},\${rmdup}\" > ${c1}.stats" >> aln_${c1}.sh 
        echo "echo All statistics have been printed to ${c1}.stats in the following order: aligned reads, aligned properly paired reads, and aligned reads with duplicates removed. Job complete at \$(date)" >> aln_${c1}.sh
	
	sbatch aln_${c1}.sh

        x=$(( $x + 1 ))

done
