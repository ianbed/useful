#PBS -l walltime=400:00:00
#PBS -l mem=10gb
#PBS -l nodes=1:ppn=1
#PBS -M ian.beddows@vai.org
#PBS -m ae
#PBS -N quantify_PolyA


DIR='/secondary/projects/bbc/research/PARC_20180710_RNA/'
SORTMERNA_DIR=${DIR}analysis/sortmerna/
ANALYSIS_DIR=${DIR}analysis/polyA/
quantPolyA=${ANALYSIS_DIR}quantPolyA.pl # the perl script that does the quantification
n_samples=0
for SAMPLE in `ls ${SORTMERNA_DIR}|grep _non_rRNA_R1.fq.gz|awk -F '_non_rRNA_R1.fq.gz' '{print $1}'`; do
#~ for SAMPLE in `ls ${SORTMERNA_DIR}|grep _non_rRNA_R1.fq.gz|awk -F '_non_rRNA_R1.fq.gz' '{print $1}'|grep SPWA25L`; do # testing on 1 sample
	OUTFILE=${ANALYSIS_DIR}$SAMPLE.polyA.quant.txt
	R1_FILE=${SORTMERNA_DIR}${SAMPLE}_non_rRNA_R1.fq.gz
	R2_FILE=${SORTMERNA_DIR}${SAMPLE}_non_rRNA_R2.fq.gz
	if [ ! -f $OUTFILE ]; then
		#~ echo "$SAMPLE"
		#~ echo "   Processing $R1_FILE .."
		#~ # Get the 5'->3' R1 reads in READ1 file
		if [ ! -f ${ANALYSIS_DIR}READS1.${SAMPLE}.ok ]; then 
			zcat $R1_FILE | perl -pe 's/\n/\t/ if $. %4' |cut -f2 > ${ANALYSIS_DIR}READS1.${SAMPLE}
			touch ${ANALYSIS_DIR}READS1.${SAMPLE}.ok
			#~ N_FULL_LENGTH_POLYA=$(zcat $R1_FILE | perl -pe 's/\n/\t/ if $. %4' |cut -f2 | grep '^AAAAAAAAAA'|wc -l)
			#~ echo "${SAMPLE}	${N_FULL_LENGTH_POLYA}" >> ${ANALYSIS_DIR}full_length_polyA.txt
		fi
		echo "   Processing $R2_FILE .."
		#~ # Get the R2 reads and reverse them to 5' -> 3' into the READ2 file
		if [ ! -f ${ANALYSIS_DIR}READS2.${SAMPLE}.ok ]; then 
			zcat $R2_FILE | perl -pe 's/\n/\t/ if $. %4' |cut -f2 | perl -ne 'chomp;$rev = reverse $_; print $rev,"\n"; '> ${ANALYSIS_DIR}READS2.${SAMPLE}
			touch ${ANALYSIS_DIR}READS2.${SAMPLE}.ok
		fi
		echo "   Quantifying polyA in $SAMPLE .."
		paste -d '\t' ${ANALYSIS_DIR}READS1.${SAMPLE} ${ANALYSIS_DIR}READS2.${SAMPLE} | ${quantPolyA} -out ${ANALYSIS_DIR}$SAMPLE.polyA.quant.txt
		
		#~ # now remove the intermediate files:
		rm ${ANALYSIS_DIR}READS1.${SAMPLE}
		rm ${ANALYSIS_DIR}READS2.${SAMPLE}
		
	fi
	((n_samples++))
done


exit

x=$(expr $n_samples \* 2) # get the number of samples * 2 (number of columns total)

# Now join all of the files:

echo "x is $x"

exit

# get samples
ls -1 ${ANALYSIS_DIR} |grep polyA.quant.txt|cut -d '.' -f1|tr '\n' '\t'|sed -e 's/^/polyA_length\t/' |sed -e 's/$/\n/' > header
paste *polyA.quant.txt|tail -n+2 | awk -F '\t' '{for(i=2;i<=118;i+=2){printf "%s ",$i;} print ""}' > data # make 118 2x the number of samples (x)
paste *polyA.quant.txt|tail -n+2 |cut -f1 > rownames
paste rownames data | sed -e 's/\s/\t/g' > body
cat header body > polyA.quant.${n_samples}.samples.txt
rm header
rm rownames
rm data
rm body
