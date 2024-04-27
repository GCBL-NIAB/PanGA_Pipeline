#!/usr/bin/perl
use Cwd qw(abs_path);

my $path= abs_path();

my $reference="/home/niab/abhisek/sp058_dna/healthy_DNAseq_LCGC/assembly/GCF_003369695.1_UOA_Brahman_1_genomic.fna";
#warn "*********your refrence sequence is $reference, if it is not true change the reference sequence in program\n*********check your adaptor sequence file for fastp\n";
$pipeline_path="/home/niab/app/PanGA_pipeline/bin";

print "mkdir out\n";

open (FILE, "$ARGV[0]");

while(my $line=<FILE>) {


if ($line=~/^$/){next;}
my @filename= split(/\s+/, $line);

my $input_file_R1=$filename[0]; 
my $input_file_R2=$filename[1]; 


my @base_name1=split("/", $input_file_R1 );

$base_name2= pop @base_name1;

my @base_name3=split("_R1", $base_name2 );

my $base_name=$base_name3 [0];
#print "$base_name\n";




print "mkdir $path/out/$base_name\n";
print "mkdir -p $path/out/$base_name/alignment\n";
print "mkdir -p $path/out/$base_name/masurca_analysis\n";
print "mkdir -p $path/out/$base_name/blast\n";
print "mkdir -p $path/out/cdhit\n";

my $out_folder="$path/out/$base_name";
my $alignment_path="$path/out/$base_name/alignment";
my $masurca_path="$path/out/$base_name/masurca_analysis";
my $cdhit_path="$path/out/cdhit";

my $trim_file1=$filename[0];
my $trim_file2=$filename[1];

my $sorted_bam=$base_name."_sorted.bam";
my $markdup_bam=$base_name."_markdup.bam";
my $rg_added_bam=$base_name. ".bam";
my $sam = $base_name.".sam";
my $bam = $base_name.".bam";



#print "$trim_file1\n";
#print "echo \" ****************************************\\n ****************************************\\n*                                  *\\n*  Welcome To PanGA pipeline         *\\n*                                    *\\n*         Created by  GCBL Group               *\\n*                                    *\n ****************************************\n ****************************************\n";
print "fastp --in1 $input_file_R1 --in2 $input_file_R2 --out1 $trim_file1 --out2 $trim_file2 -a --thread 16 -p --overrepresentation_analysis -l 50 -q 20 -u 20 -h $out_folder/$base_name\_report.html -j $out_folder/$base_name\_report.json -R $out_folder/$base_name\_report --trim_front1 0 --trim_tail1 1 --trim_front2 0 --trim_tail2 1 --dont_overwrite \n\n";                          

print "bowtie2 -p 60 -x $reference -1 $trim_file1 -2 $trim_file2 -S $alignment_path$sam 2>> $alignment_path$base_name.log\n";
print "samtools view -h -S -@ 60 -T $reference -b -o $alignment_path$bam $alignment_path$sam\n";
print "samtools fastq -@ 60 -f 12 $alignment_path$bam -1 $alignment_path$base_name\_mateUnmapped_R1.fq -2 $alignment_path$base_name\_mateUnmapped_R2.fq \n";
print "samtools fastq -@ 60 -f 68 -F 8 > $alignment_path$base_name\_R1_matemap.fq $alignment_path$bam\n";
print "samtools fastq -@ 60 -f 132 -F 8 > $alignment_path$base_name\_R2_matemap.fq $alignment_path$bam\n";
#print "samtools view -@ 60 -h -f 8 -F 4 -o $alignment_path$base_name\_Link.bam $alignment_path/$bam\n";
#print "rm $alignment_path/$bam $alignment_path/$sam\n";
print "echo \"$base_name Alignment Completed\"\n\n";
print "cd $masurca_path\n";
print "echo \"\" > abcd.fna\n";
print "echo \"DATA \\nPE= pe 350 50 $alignment_path$base_name\_mateUnmapped_R1.fq $alignment_path$base_name\_mateUnmapped_R2.fq\\nPE= s1 350 50 $alignment_path/$base_name\_R1_matemap.fq\\nPE= s2 350 50 $alignment_path/$base_name\_R2_matemap.fq\\nREFERENCE= ./abcd.fna\\nEND \\n\\n\\n\\nPARAMETERS\\nGRAPH_KMER_SIZE=auto\\nUSE_LINKING_MATES=1\\nKMER_COUNT_THRESHOLD = 1\\nNUM_THREADS=30\\nJF_SIZE=2000000000\\nDO_HOMOPOLYMER_TRIM=0\\nEND \" > masurca_config_file.txt\n";
print "masurca masurca_config_file.txt\n";
print "./assemble.sh > masurca.log\n";
print "echo \"$base_name Masurca Assembly Completed\"\n\n";
print "cd $path/out/$base_name/blast\n";
print "perl $pipeline_path/fasta_slection_on_length.pl $masurca_path/CA.contigs.fa > contigs.fa\n";
print "fasta2lineage contigs.fa > centrifuge_linage_ev20.txt\n";
print "awk \'{print \$0}\' centrifuge_linage_ev20.txt \|grep -B1 -v \"\# 0 hits \" \|awk -F \",\" \'!/#/{print \$1,\$2,\$3,\$4,\$7,\$8,\$9,\$10,\$11}\'\| awk \'/Chordata/{print \$1}\' > chordata_id.txt\n";
print "awk \'{print \$0}\' centrifuge_linage_ev20.txt\|grep -B1 \"\#0\" \|awk \'!/\#0/{print \$0}\'|awk \'!/--/{print \$1}\' > zerohit_id.txt\n";
print "sed \'s\/\#//g\' zerohit_id.txt > zero_hit.txt\n";
print "cat zero_hit.txt chordata_id.txt > final_contig_id.txt\n";
print "perl $pipeline_path/fasta_extract.pl final_contig_id.txt contigs.fa > final_contig.fa\n";
print "cd $cdhit_pat\n";
print "cat $path/out/$base_name/blast/final_contig.fa > cd_hit_input.fa\n";
print "cd-hit-est -i cd_hit_input.fa -o cd_hit_out.fa -T 10 -aS 0.8 -g 1 -c 0.9 -M 0\n";
print "perl $pipeline_path/fasta_header_rename.pl cd_hit_out.fa > NRNS.fa\n";
}


