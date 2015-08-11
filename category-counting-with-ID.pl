use strict;
use Text::ParseWords;
my %vh;
my %nh;
my $cnt=0;
my $cntt;
my $category;
my $ID;
my $f1 = shift @ARGV;
my $id = shift @ARGV;
my $cat = shift @ARGV;

open(F1,$f1);
while (my $line = <F1>) {
	chomp $line;
	$line =~ s/\r|\'|\"//g;
	my $emptytest=$line;
	$emptytest =~ s/[^a-zA-Z0-9]*//g;
	$emptytest =~ s/\s+//g;
	if($emptytest ne ""){
		my @tmp=parse_line('\t',0,$line);
		$tmp[$cat]=~s/^\s+//g;
		$tmp[$cat]=~s/\s+$//g;
		$tmp[$id]=~s/\s+//g;
		my ($idd)=uc($tmp[$id]);
		if($cnt<1){
			$category=$tmp[$cat];
			$ID=$tmp[$id];
		}
		else{
			if($tmp[$cat] eq ""){
						$nh{"NA"}++;
						$vh{"NA"}.="$idd;";
			}
			else{
				my @tmpp=split(/\;/,$tmp[$cat]);
				for($cntt=0;$cntt<=$#tmpp;$cntt++){
						$tmpp[$cntt]=~s/^\s+//g;
						$tmpp[$cntt]=~s/\s+$//g;
						my ($name)=uc($tmpp[$cntt]);
						$nh{$name}++;
						$vh{$name}.="$idd;";
				}
			}
		}
		$cnt++;
	}
}
$cnt--;
close F1;

print "$category\t$ID\tUnique\tCountAll\tCountUnique\tTotal\n";
foreach my $k (keys %nh){
	my @a=split(/\;/,$vh{$k});
	my @au = do { my %seen; grep { !$seen{$_}++ } @a };
	my $c=$#au+1;
	print "$k\t$vh{$k}\t@a\t$nh{$k}\t$c\t$cnt\n";
}

__END__

perl category-counting-with-ID.pl /cygdrive/l/Elite/LARS/2015/january/Bodil\ mus/Copy\ of\ CH12\ AID-YFP\ IP\ stim\ 2\ unstim-L2H\ corrigated\ Selected\ Score\ 5\ PV\ 05.txt 0 7 > /cygdrive/l/Elite/LARS/2015/january/Bodil\ mus/Score5PV05GOcountMolFunc.txt 