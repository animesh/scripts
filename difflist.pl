use warnings;
use strict;
open(F1,$ARGV[0]);
open(F2,$ARGV[1]);
my @list=<F1>;
my @gop=<F2>;

	@list = sort { uc($a) cmp uc($b) } @list;
	@gop = sort { uc($a) cmp uc($b) } @gop;

my $cnt=0;
my %match;
for(my $c1=0;$c1<=$#list;$c1++){
	$list[$c1]=~s/\n|\r//g;
	for(my $c2=$cnt;$c2<=$#gop;$c2++){
		$gop[$c2]=~s/\n|\r//g;;
		if(uc($gop[$c2]) eq uc($list[$c1])){
				$match{$list[$c1]}++;
		}
		else{next;}
	}
}

foreach (@list){
		print "$_\t$match{$_}\n";
}

__END__

time perl matchlist.pl /cygdrive/x/Elite/LARS/2013/august/SorrySoaryAsses/MCR5R5and9and10and11and12at5.csv /cygdrive/x/Elite/LARS/2013/august/SorrySoaryAsses/uniprot-keywordAKW-0645.list | wc
      5      70    1236

real    0m32.531s
user    0m32.119s
sys     0m0.077s
