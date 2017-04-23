use strict;
use Text::ParseWords;
open(F1,$ARGV[0]);
my $s1=$ARGV[1];
my $s2=$ARGV[2];
my $s3=$ARGV[3];
my $s4=$ARGV[4];
my $s5=$ARGV[5];
my %val1;
my %tm1;
my %val2;
my %tm2;
my %tm;
my $lc;
my $qt=0.05;

while(my $l=<F1>){
	$lc++;
	if($lc>1){
		chomp $l;
		$l =~ s/\r//g;
		my @tmp1=parse_line(',',0,$l);
		my @tmp2=split(/;/,$tmp1[$s1]);
		for(my $c1=0;$c1<=$#tmp2;$c1++){
			if($tmp1[$s5]=~/mbiguous/ and $tmp1[$s2]>0 and $tmp1[$s4]<$qt and $tmp1[$s3]=~/Berit_[7-9]_AID_YFP/){
				$val1{$tmp2[$c1]}+=($tmp1[$s2]);
				$tm1{$tmp2[$c1]}++;
			}
			if($tmp1[$s5]=~/mbiguous/ and $tmp1[$s2]>0 and $tmp1[$s4]<$qt and $tmp1[$s3]=~/Berit_1[0-2]_AID_YFP/){
				$val2{$tmp2[$c1]}+=($tmp1[$s2]);
				$tm2{$tmp2[$c1]}++;
			}
			$tm{$tmp2[$c1]}++;
		}
	}
}

foreach (keys %tm){
	if($val1{$_}>0 && $val2{$_}>0){
		print "$_,",$val2{$_}/$val1{$_},",$val1{$_},$val2{$_},$tm1{$_},$tm2{$_},$tm{$_}\n";
	}
	elsif($val1{$_}eq"" && $val2{$_}){
		print "$_,",$val2{$_},",$val1{$_},$val2{$_},$tm1{$_},$tm2{$_},$tm{$_}\n";
	}
	elsif($val2{$_}eq"" && $val1{$_}){
		print "$_,",1/$val1{$_},",$val1{$_},$val2{$_},$tm1{$_},$tm2{$_},$tm{$_}\n";
	}
	elsif($val1{$_} && $val2{$_}){
		print "$_,",1,"$val2{$_},$tm1{$_},$tm2{$_},$tm{$_}\n";
	}
}


__END__

perl scorecomp.pl /cygdrive/c/Users/animeshs/SkyDrive/B2T1.csv 8 16 34 17 5 > B2T1AreaParsedRatio.csv
