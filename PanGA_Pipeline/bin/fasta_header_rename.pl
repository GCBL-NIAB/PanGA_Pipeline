#!/usr/bin/perl

open(FILE1,"$ARGV[0]"); 	
my $i=1;

while ($line1=<FILE1>){
if ($line1 =~/^>/) {print ">contig_$i\n";$i++;next;}

print "$line1";



}

close(FILE1);
