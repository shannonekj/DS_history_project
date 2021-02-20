#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J cmpssALL
#SBATCH -e 18_compress_fastq_data.barcodedirs.%j.err
#SBATCH -o 18_compress_fastq_data.barcodedirs.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=02:00:00

set -e # exits upon failing command
set -v # verbose -- all lines
set -x # trace of all commands after expansion before execution


# set up directories
data_dir="/home/sejoslin/projects/DS_history/data"

cd $data_dir

#######################
### Set Up Barcodes ###
#######################

for i in BMAG0*
do
if [[ $i == "BMAG044" ]]
then
  barcode="TTAGGC,TGACCA,ACAGTG,GCCAAT"
  elif [[ $i == "BMAG045" ]]
  then
    barcode="CAGATC,ACTTGA,GATCAG,TAGCTT"
    elif [[ $i == "BMAG046" ]]
    then
      barcode="GGCTAC,CTTGTA,AGTCAA,AGTTCC"
      elif [[ $i == "BMAG047" ]]
      then
        barcode="ATGTCA,CCGTCC,GTCCGC,GTGAAA"
        elif [[ $i == "BMAG048" ]]
        then
          barcode="GTGGCC,CGTACG,ATTCCT,ACTGAT"
          elif [[ $i == "BMAG049" ]]
          then
            barcode="GTTTCG"
            elif [[ $i == "BMAG055" ]]
	    then
		barcode="CCGTCC,CTTGTA,GGCTAC,GTGAAA"
		else
		echo $i " does not match given datasets!"
              fi
cd $i

	######################
	### Compress Split ###
	###     fastq      ###
	######################
# create scripts to compress each BMAG0??'s barcode directories individually	
	wc=$(wc -l indexid.list | awk '{print $1}') # number of lines
	x=1
	while [ $x -le $wc ]
	do
		string="sed -n ${x}p indexid.list"
		str=$($string)
		var=$(echo $str | awk -Ft '{print $1}')
		set -- $var
		c1=$1
		echo "#!/bin/bash" > 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH --mail-user=sejoslin@ucdavis.edu" >> 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH --mail-type=ALL" >> 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH -J ${c1}.${i}" >> 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH -e 18_compress_fastq.${i}.${c1}.%j.err" >> 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH -o 18_compress_fastq.${i}.${c1}.%j.out" >> 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH -c 20" >> 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH -p high" >> 18_compress_fastq.${i}.${c1}.sh
		echo "#SBATCH --time=1-20:00:00" >> 18_compress_fastq.${i}.${c1}.sh
		echo "" >> 18_compress_fastq.${i}.${c1}.sh
		echo "set -e # exits upon failing command" >> 18_compress_fastq.${i}.${c1}.sh
		echo "set -v # verbose -- all lines" >> 18_compress_fastq.${i}.${c1}.sh
		echo "set -x # trace of all commands after expansion before execution" >> 18_compress_fastq.${i}.${c1}.sh
		echo "" >> 18_compress_fastq.${i}.${c1}.sh
		echo "cd ${data_dir}/${i}/$c1" >> 18_compress_fastq.${i}.${c1}.sh
		echo "echo Compressing Ht ${c1} fastq files in $i on \$(date | awk '{print \$4 \" \" \$3 \$2 \$6}')" >> 18_compress_fastq.${i}.${c1}.sh
		echo "lzma Ht*.fastq" >> 18_compress_fastq.${i}.${c1}.sh
		echo "echo Compression complete at \$(date | awk '{print \$4 \" \" \$3 \$2 \$6}')" >> 18_compress_fastq.${i}.${c1}.sh
		echo "echo Compressing R1 R2 R3 at " >> 18_compress_fastq.${i}.${c1}.sh
		echo "lzma BMAG*.fastq" >> 18_compress_fastq.${i}.${c1}.sh
		echo "Compression of R1, R2, and R3 completed at \$(date | awk '{print \$4 \" \" \$3 \$2 \$6}')" >> 18_compress_fastq.${i}.${c1}.sh
		sbatch 18_compress_fastq.${i}.${c1}.sh
	x=$(( $x + 1 ))
	done
cd ${data_dir}
done


