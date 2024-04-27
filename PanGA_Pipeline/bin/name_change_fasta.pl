#!/usr/bin/perl                                         #usage:

open(FILE,"$ARGV[0]");

my $i=0;
while (my $line=<FILE>){

if($line=~/^>/){ print ">panseq_$i\n"; $i++; next;}

print "$line";



}



close(FILE);

