#!/usr/bin/perl




open(FILE,"$ARGV[0]")|| die "\nInput data file has not been provide to programm\n ****EXITING*****\n\n";
print "please provide the bin size such as 50/100/XX\n\n"; 
$bin_size=<STDIN>;
chomp $bin_size;print "#bin size is $bin_size \n";
#print "\n\n\n";
#$bin_size=50; ##please change the bin size here
my @value=();

while($line=<FILE>){
chomp $line;
@nano=split(/\s+/,$line);
push (@value,"$nano[0]");

}


my @n_value= sort {$a<=>$b} @value;

my $Highest_value= pop @n_value;
 push(@n_value, $Highest_value);
#print "highest value\t$Highest_value\n";
$Max_value=  int($Highest_value/$bin_size);
$Max_value=$Max_value+1; 
my $i=$bin_size;my $count=0;
foreach $morsel(@n_value){
CHECK:
if($morsel<$i){$count++;}
else{ print "$i\t$count\n"; $count=0; $i=$i+$bin_size; goto CHECK;}


}
 print "$i\t$count\n";
