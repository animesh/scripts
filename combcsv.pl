use warnings;
use strict;
my $f1=shift;
my $f2=shift;
open(F1,$f1);
open(F2,$f2);
my $mc1=0;
my @list=<F1>;
my @gop=<F2>;
@list = sort { uc($a) cmp uc($b) } @list;
@gop = sort { uc($a) cmp uc($b) } @gop;
my $cnt=0;
my %match;
my %mf;
my %mf1;
my %mf2;
my $title;

for(my $c1=0;$c1<=$#list;$c1++){
	$list[$c1]=~s/\n|\r//g;
	if($c1==0){$title=$list[$c1];}
	my @tmp1=split(/,/,$list[$c1]);
	for(my $c2=$cnt;$c2<=$#gop;$c2++){
		$gop[$c2]=~s/\n|\r//g;;
		my @tmp2=split(/,/,$gop[$c2]);
		my $v1="$tmp1[$mc1]"; #-$tmp1[$mc2]-$tmp1[$mc3]";
		my $v2="$tmp2[$mc1]"; #-$tmp2[$mc2]-$tmp2[$mc3]";
		if(uc($v1) eq uc($v2)){
			$match{$v1}="$list[$c1],$gop[$c2]";
			delete $list[$c1]; # saves a sec
			delete $gop[$c2];
			$cnt=$c2+1;
			$mf{$v1}++;
			last;
		}
		else{$mf1{$v1}="$list[$c1]";$mf2{$v2}="$gop[$c2]";$mf{$v1}++;$mf{$v2}++;}
 	}
}

foreach (keys %mf){
	if($match{$_}){
		print "B,$_,$match{$_},$mf{$_},$f1-$f2\n";
	}
	elsif($mf1{$_}){
		print "M,$_,$mf1{$_},$gop[-1],$mf{$_},$f1\n";
	}
	elsif($mf2{$_}){
		print "C,$_,$list[-1],$mf2{$_},$mf{$_},$f2\n";
	}
	else{
		print "NA,$_,$list[-1],$gop[-1],$mf{$_},NA\n";
	}
}

__END__

perl combcsv.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Ani/Jenni/140320\ MS2\ Tromsø\ IPp62\ DHA/MouseStimDHA.txt /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Ani/Jenni/140320\ MS2\ Tromsø\ IPp62\ DHA/MouseUnstimCtrl.txt > /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Ani/Jenni/140320\ MS2\ Tromsø\ IPp62\ DHA/Stim2Ctrl.txt

