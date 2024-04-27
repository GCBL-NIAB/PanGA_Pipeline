#!/usr/bin/perl

use strict;

#print"\nEnter the name of file as comand argument\n";

my $filename=$ARGV[0];
chomp $filename;
#print"$filename\n";

warn "\n### please provide sequence cuttoff length\n";



#$cuttoff_length= $ARGV[1]; 
my $cuttoff_length= 1000;
chomp $cuttoff_length;

my $seq="";
my $p=0;
my $name="";
open(FILE,$filename);
while(my $line=<FILE>)
{chomp $line;
if($line=~/\r$/){chop $line;}
if ($line=~m/^>/){ if ($p>$cuttoff_length) { print"$name\n$seq\n"; }
				$name=$line;$p=0; $seq=""; next;    
		 }



$seq=$seq.$line;
$b= length($line);

$p=$p+$b;





#print"$b\n\n";
}

 if ($p>1000) { print"$name\n$seq\n"; }
				


#README
#this code is to calculate the length of fasta file given. Output will be header and tab distance and then length of fasta sequence.
#Output will be displaced on terminal  and it can be saved as file from terminal using ">".
#Input can be single fasta or many fasta sequence files.

