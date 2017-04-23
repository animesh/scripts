#!/usr/bin/perl
# getorder.pl     sharma.animesh@gmail.com     2009/03/09 10:01:28
#>codbac-190o01.fb140_b1.SCF length=577 sp3=clipped

while(<>){
	if($_=~/^>/){
	$cnt++;
    my @tmp=split(/\s+/,$_);
    my $namestr=substr($tmp[0],8,8);
    my $namesubstr=substr($tmp[0],8,6);
    $hitname{$namesubstr}++;
	$hitpos{$namestr}++;
	#print "$namestr\t$namesubstr\t$hitpos{$namestr}\n";	
	}
}

foreach my $w (keys %hitname) {
	 my $rname=$w.".r";
	 my $fname=$w.".f";
	$cnt2++;
		if($hitpos{$rname} and $hitpos{$fname}){
			$cseq++;
 			print "$w\t$fname\t$rname\t-\t$hitpos{$fname}\t$hitpos{$rname}\n";
		}
}

print "$cseq Total Pair from $cnt2 Elements in $cnt strings\n";


