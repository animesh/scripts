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
if($num==0){
	@list = sort { uc($a) cmp uc($b) } @list;
	@gop = sort { uc($a) cmp uc($b) } @gop;
}
else{
	@list = map { join ',', sort {$a <=> $b} split /,/} @list;
	@gop = map { join ',', sort {$a <=> $b} split /,/} @gop;
}
my $cnt=0;
my %match;
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
				$match{$tmp1[$mc]}.="$tmp2[$oc],$list[$c1],$gop[$c2],";
				delete $list[$c1]; # saves a sec
				delete $gop[$c2];
				$cnt=$c2+1;
				last;
			}
			else{next;}
 		}
		else{
			if(($tmp1[$mc]+0)==($tmp2[$oc]+0)){
				$match{$tmp1[$mc]}.="$tmp2[$oc],$list[$c1],$gop[$c2],";
				delete $list[$c1]; # saves a sec
				delete $gop[$c2];
				$cnt=$c2+1;
				last;
			}
			else{next;}
 		}
 		
 	}
}
foreach (keys %match){
	if($match{$_}){
		print "$_,$match{$_}\n";
	}
}

__END__


perl matchlist.pl /cygdrive/l/Elite/Aida/Sub2.csv /cygdrive/l/Elite/Aida/Subject21.csv > /cygdrive/l/Elite/Aida/Sub2with21.csv
