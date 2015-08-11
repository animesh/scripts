use warnings;
use strict;
open(F1,$ARGV[0]);
my @list=<F1>;
@list = sort { uc($a) cmp uc($b) } @list;
my %match;
for(my $c1=0;$c1<=$#list;$c1++){
	$list[$c1]=~s/\n|\r//g;
	my @tmp1=split(/GN\=/,$list[$c1]);
	my @tmp2=split(/\s+/,$tmp1[1]);
	print "$tmp2[0],$list[$c1]\n"
}

