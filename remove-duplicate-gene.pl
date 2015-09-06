use strict;
use Text::ParseWords;
use Scalar::Util qw(looks_like_number);
my %vh;
my %nh;
my %ch;
my $gn=1;
my $cnt;

my $f1 = shift @ARGV;
open (F1, $f1) || die "can't open \"$f1\": $!";
my $lc;
while (my $line = <F1>) {
	$lc++;
	$line =~ s/\r//g;
	chomp $line;
	if($lc==1){$vh{"header"}="$line";}
	else{
		$line =~ s/\'/-/g;
		my @tmp=parse_line('\t',0,$line);
		my ($name)=$tmp[$gn] =~ m/GN *= *([^,; ]*)/;
		#print "$name\n";
		$name=~s/\s+//g;
		if($name ne ""){$nh{$name}++}
		else{$name=$tmp[0];$nh{$name}++}
		for($cnt=0;$cnt<=$#tmp;$cnt++) {
			$tmp[$cnt] =~ s/^\s+|\s+$//;
			if($tmp[$cnt] eq ""){next;}
			elsif(looks_like_number($tmp[$cnt]) and $tmp[$cnt]==0){$vh{"$name-$cnt"}=0;}
			elsif(looks_like_number($tmp[$cnt]) and $tmp[$cnt]==1){$vh{"$name-$cnt"}=1;}
			elsif (looks_like_number($tmp[$cnt])){
				if($vh{"$name-$cnt"}<abs($tmp[$cnt])){
					$vh{"$name-$cnt"}=$tmp[$cnt];
				}
			}
			else{
				$tmp[$cnt]=~s/,/ /g;
				$vh{"$name-$cnt"}.="$tmp[$cnt];";
			}
		}
	}
}
close F1;

$lc=0;
foreach my $ncc (keys %nh){
	$lc++;
	if($lc==1){print "Gene\t",$vh{"header"},"\tCount\tNumber\n";}
	print "$ncc\t";
	for(my $c=0;$c<$cnt;$c++){
		print $vh{"$ncc-$c"},"\t";
	}
	print "$nh{$ncc}\t$lc\n";
}

__END__

$ perl remove-duplicate-gene.pl /cygdrive/x/Qexactive/Berit_Sissel/B005/MCR22ProteinsB5.csv | sed 's/\,/ /g' | awk '{print $3}' | sort | uniq -c
   4105 149
    101 298

