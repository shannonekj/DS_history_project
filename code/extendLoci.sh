#!/bin/bash -l

F1=$1
n=$(wc -l $F1 | awk '{print $1}')

x=1
while [ $x -le $n ] 
do

                string="sed -n ${x}p $F1"
                str=$($string)

                var=$(echo $str | awk '{print $1}')
                set -- $var
                c1=$1   ### Loci name goes here ###


      ~/iksaglam/bin/PriceTI -fpp ${c1}_R1.fastq ${c1}_R2.fastq 300 90 -icf ${c1}.fasta 1 1 5 -nc 1 -dbmax 88 -mol 40 -mpi 80 -target 100 0 -o ${c1}_contig.fasta


                x=$(( $x + 1 ))

done
