#!/usr/bin/perl						#usage:

open(FILE,"$ARGV[0]");   
			

while (my $line=<FILE>){
@contig=split(/,|\s+|\n/,$line);


&EXTRACT($contig[0]);


}

close(FILE);






sub EXTRACT{
my $seq=$_[0];
chomp $seq;
my $check=0; my @name=();
open(IN,"$ARGV[1]");

while(my $tine=<IN>){
chomp $tine;

if($tine=~/^>/){ @name=split(/\s+/,$'); if($name[0] eq $seq) { $check=1; }
					else{	if($check==1){last;}	}
		}


if($check==1){print "$tine\n"; }

} 

close(IN);
return;
}


