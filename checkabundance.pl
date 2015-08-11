use strict;
use Text::ParseWords;
open(F1,$ARGV[0]);
open(F2,$ARGV[1]);
my %id;
my %val;
my $prot=1;
my $abd=2;

while(my $l=<F1>){
	chomp $l;
	$l=~s/\r//g,
	my @tmp=parse_line(',',0,$l);
	$id{$tmp[$prot]}++;
}
close F1;

while(my $l2=<F2>){
	chomp $l2;
	$l2=~s/\r//g,
	my @tmp2=parse_line(',',0,$l2);
	if($tmp2[$abd]>0){
		$val{$tmp2[$prot]}=$tmp2[$abd];
	}
}
close F2;

foreach (keys %id){
	if($val{$_}>0){
        	print "$_,$id{$_},$val{$_}\n";
        }
}


__END__

wget http://pax-db.org/dao/7955-Spectral_counting_D.rerio_GPM_Oct_2012.txt
wget http://www.uniprot.org/jobs/2013110551MXXBB3VF.tab
perl checkabundance.pl /cygdrive/x/Elite/Mohmd/ZF/7955-Spectral_counting_D.rerio_GPM_Oct_2012.csv