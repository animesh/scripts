use strict;
use Text::ParseWords;
open(F1,$ARGV[0]);
my $unid=0;
my $s1=$ARGV[1];
my $s2=$ARGV[2];
my $lv=$ARGV[3];
my %nm;
my %id;
my %val1;
my %val2;
my $lc=0;
my %fnd;
my %hdr;

while(my $l=<F1>){
	$lc++;
	if($lc>$lv){
		$l =~ s/\r|\n|\'//g;
		my @tmp=parse_line(',',0,$l);
		$nm{$tmp[$unid]}=$l;
		$id{$tmp[$unid]}++;
		my @tmp1=split(/\-/,$s1);
		for(my $c1=0;$c1<=$#tmp1;$c1++){
			if($tmp[$tmp1[$c1]]>0){
				$val1{$tmp[$unid]}+=$tmp[$tmp1[$c1]];
				$fnd{$tmp[$unid]}++;
			}
		}
		my @tmp2=split(/\-/,$s2);
		for(my $c2=0;$c2<=$#tmp2;$c2++){
			if($tmp[$tmp2[$c2]]>0){
				$val2{$tmp[$unid]}+=$tmp[$tmp2[$c2]];
				$fnd{$tmp[$unid]}++;
			}
		}
	}
	else{$hdr{$lc}=$l}
}

foreach (keys %hdr){
	print "HDR-$_,Ratio [$s2/$s1],FoundIn,$hdr{$_}";
}

foreach (keys %id){
	if($val1{$_}>0 && $val2{$_}>0){
		print "$_,",$val2{$_}/$val1{$_},",$fnd{$_},$nm{$_},$id{$_}\n";
	}
	elsif($val1{$_}==0 && $val2{$_}){
		print "$_,",$val2{$_},",$fnd{$_},$nm{$_},$id{$_}\n";
	}
	elsif($val2{$_}==0 && $val1{$_}){
		print "$_,",1/$val1{$_},",$fnd{$_},$nm{$_},$id{$_}\n";
	}
	elsif($val1{$_} && $val2{$_}){
		print "$_,A [$val1{$_}-$val2{$_}],$fnd{$_},$nm{$_},$id{$_}\n";
	}
	else{
		print "$_,NA [$val1{$_}-$val2{$_}],$fnd{$_},$nm{$_},$id{$_}\n";
	}
}


__END__

$ perl areacomp.pl /cygdrive/c/Users/animeshs/SkyDrive/B4T1r.csv 7-8-9 10-11-12  2 > /cygdrive/c/Users/animeshs/SkyDrive/B4T1rAreaRatio.csv
