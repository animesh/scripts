use warnings;
use strict;
open(F1,$ARGV[0]);
open(F2,$ARGV[1]);
my $mc=$ARGV[2];
my $oc=$ARGV[3];
my $num=$ARGV[4];
if(!$ARGV[2]){$mc=0;}
if(!$ARGV[3]){$oc=$mc;}
if(!$ARGV[4]){$num=0;}
my @list=<F1>;
my @gop=<F2>;
@list = sort { uc($a) cmp uc($b) } @list;
@gop = sort { uc($a) cmp uc($b) } @gop;
my $cnt=0;
my %match;
my %mf;
my %mf1;
my %mf2;
for(my $c1=0;$c1<=$#list;$c1++){
	$list[$c1]=~s/\n|\r//g;
	my @tmp1=split(/,/,$list[$c1]);
	for(my $c2=$cnt;$c2<=$#gop;$c2++){
		$gop[$c2]=~s/\n|\r//g;;
		my @tmp2=split(/,/,$gop[$c2]);
		#$tmp1[$mc]=~s/\s+|\r//g; #take twice the time
		if($num==0){
			$tmp1[$mc]=~s/\s+//g;
			$tmp2[$oc]=~s/\s+//g;
			if(uc($tmp1[$mc]) eq uc($tmp2[$oc])){
				$match{$tmp1[$mc]}="$list[$c1],$gop[$c2]";
				delete $list[$c1]; # saves a sec
				delete $gop[$c2];
				$cnt=$c2+1;
				$mf{$tmp1[$mc]}++;
				last;
			}
			else{$mf1{$tmp1[$mc]}="$list[$c1]";$mf2{$tmp2[$oc]}="$gop[$c2]";$mf{$tmp1[$mc]}++;$mf{$tmp2[$oc]}++;}
 		}
 	}
}
foreach (keys %mf){
	if($match{$_}){
		print "$_,$match{$_},$mf{$_},M\n";
	}
	elsif($mf1{$_}){
		print "$_,$mf1{$_},$gop[-1],$mf{$_},F1\n";
	}
	elsif($mf2{$_}){
		print "$_,$list[-1],$mf2{$_},$mf{$_},F2\n";
	}
	else{
		print "$_,$list[-1],$gop[-1],$mf{$_},NA\n";
	}
}

__END__

perl mergelist.pl /cygdrive/l/Elite/Celine/HLproteinGroups24.csv /cygdrive/l/Elite/Celine/LHproteinGroups24.csv 2>0 > /cygdrive/l/Elite/Celine/HLLHproteinGroups24Merge.csv
perl mergelist.pl /cygdrive/l/Elite/Celine/LHproteinGroups24.csv /cygdrive/l/Elite/Celine/HLproteinGroups24.csv 2>0 > /cygdrive/l/Elite/Celine/LHHLproteinGroups24Merge.csv

wc /cygdrive/l/Elite/Celine/*proteinGroups24*.csv                                1648   12997  913041 /cygdrive/l/Elite/Celine/HLLHproteinGroups24.csv
   1732   13437  853822 /cygdrive/l/Elite/Celine/HLLHproteinGroups24Merge.csv
   4413   10206  476341 /cygdrive/l/Elite/Celine/HLproteinGroups24.csv
   1732   13437  850188 /cygdrive/l/Elite/Celine/LHHLproteinGroups24Merge.csv
   3375    9203  466457 /cygdrive/l/Elite/Celine/LHproteinGroups24.csv
  12900   59280 3559849 total
