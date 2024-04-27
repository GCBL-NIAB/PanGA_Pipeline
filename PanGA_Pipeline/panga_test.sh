mkdir out
mkdir /home/niab/app/PanGA_pipeline/out/test
mkdir -p /home/niab/app/PanGA_pipeline/out/test/alignment
mkdir -p /home/niab/app/PanGA_pipeline/out/test/masurca_analysis
mkdir -p /home/niab/app/PanGA_pipeline/out/test/blast
mkdir -p /home/niab/app/PanGA_pipeline/out/cdhit
fastp --in1 /home/niab/app/PanGA_pipeline/test/test_R1.fastq.gz --in2 /home/niab/app/PanGA_pipeline/test/test_R2.fastq.gz --out1 /home/niab/app/PanGA_pipeline/test/test_R1.fastq.gz --out2 /home/niab/app/PanGA_pipeline/test/test_R2.fastq.gz -a --thread 16 -p --overrepresentation_analysis -l 50 -q 20 -u 20 -h /home/niab/app/PanGA_pipeline/out/test/test_report.html -j /home/niab/app/PanGA_pipeline/out/test/test_report.json -R /home/niab/app/PanGA_pipeline/out/test/test_report --trim_front1 0 --trim_tail1 1 --trim_front2 0 --trim_tail2 1 --dont_overwrite 

bowtie2 -p 60 -x /home/niab/abhisek/sp058_dna/healthy_DNAseq_LCGC/assembly/GCF_003369695.1_UOA_Brahman_1_genomic.fna -1 /home/niab/app/PanGA_pipeline/test/test_R1.fastq.gz -2 /home/niab/app/PanGA_pipeline/test/test_R2.fastq.gz -S /home/niab/app/PanGA_pipeline/out/test/alignmenttest.sam 2>> /home/niab/app/PanGA_pipeline/out/test/alignmenttest.log
samtools view -h -S -@ 60 -T /home/niab/abhisek/sp058_dna/healthy_DNAseq_LCGC/assembly/GCF_003369695.1_UOA_Brahman_1_genomic.fna -b -o /home/niab/app/PanGA_pipeline/out/test/alignmenttest.bam /home/niab/app/PanGA_pipeline/out/test/alignmenttest.sam
samtools fastq -@ 60 -f 12 /home/niab/app/PanGA_pipeline/out/test/alignmenttest.bam -1 /home/niab/app/PanGA_pipeline/out/test/alignmenttest_mateUnmapped_R1.fq -2 /home/niab/app/PanGA_pipeline/out/test/alignmenttest_mateUnmapped_R2.fq 
samtools fastq -@ 60 -f 68 -F 8 > /home/niab/app/PanGA_pipeline/out/test/alignmenttest_R1_matemap.fq /home/niab/app/PanGA_pipeline/out/test/alignmenttest.bam
samtools fastq -@ 60 -f 132 -F 8 > /home/niab/app/PanGA_pipeline/out/test/alignmenttest_R2_matemap.fq /home/niab/app/PanGA_pipeline/out/test/alignmenttest.bam
echo "test Alignment Completed"

cd /home/niab/app/PanGA_pipeline/out/test/masurca_analysis
echo "" > abcd.fna
echo "DATA \nPE= pe 350 50 /home/niab/app/PanGA_pipeline/out/test/alignmenttest_mateUnmapped_R1.fq /home/niab/app/PanGA_pipeline/out/test/alignmenttest_mateUnmapped_R2.fq\nPE= s1 350 50 /home/niab/app/PanGA_pipeline/out/test/alignment/test_R1_matemap.fq\nPE= s2 350 50 /home/niab/app/PanGA_pipeline/out/test/alignment/test_R2_matemap.fq\nREFERENCE= ./abcd.fna\nEND \n\n\n\nPARAMETERS\nGRAPH_KMER_SIZE=auto\nUSE_LINKING_MATES=1\nKMER_COUNT_THRESHOLD = 1\nNUM_THREADS=30\nJF_SIZE=2000000000\nDO_HOMOPOLYMER_TRIM=0\nEND " > masurca_config_file.txt
masurca masurca_config_file.txt
./assemble.sh > masurca.log
echo "test Masurca Assembly Completed"

cd /home/niab/app/PanGA_pipeline/out/test/blast
perl /home/niab/app/PanGA_pipeline/bin/fasta_slection_on_length.pl /home/niab/app/PanGA_pipeline/out/test/masurca_analysis/CA.contigs.fa > contigs.fa
fasta2lineage contigs.fa > centrifuge_linage_ev20.txt
awk '{print $0}' centrifuge_linage_ev20.txt |grep -B1 -v "# 0 hits " |awk -F "," '!/#/{print $1,$2,$3,$4,$7,$8,$9,$10,$11}'| awk '/Chordata/{print $1}' > chordata_id.txt
awk '{print $0}' centrifuge_linage_ev20.txt|grep -B1 "#0" |awk '!/#0/{print $0}'|awk '!/--/{print $1}' > zerohit_id.txt
sed 's/#//g' zerohit_id.txt > zero_hit.txt
cat zero_hit.txt chordata_id.txt > final_contig_id.txt
perl /home/niab/app/PanGA_pipeline/bin/fasta_extract.pl final_contig_id.txt contigs.fa > final_contig.fa
cd 
cat /home/niab/app/PanGA_pipeline/out/test/blast/final_contig.fa > cd_hit_input.facd-hit-est -i cd_hit_input.fa -o cd_hit_out.fa -T 10 -aS 0.8 -g 1 -c 0.9 -M 0
perl /home/niab/app/PanGA_pipeline/bin/fasta_header_rename.pl cd_hit_out.fa > NRNS.fa
