use strict;
use Text::ParseWords;
use Scalar::Util qw(looks_like_number);
my %vh;
my %nh;
my $cnt=0;

my $f1 = shift @ARGV;
open (F1, $f1) || die "can't open \"$f1\": $!";
my $lc;
while (my $line = <F1>) {
	$lc++;
	$line =~ s/\r//g;
	$line =~ s/\'/-/g;
	chomp $line;
	my @tmp=parse_line('\t',0,$line);
	if($lc==1){$cnt=$#tmp;$vh{"header"}="$line\tColNum$cnt";}
	else{
		my $name=$tmp[0];
		$nh{$name}++;
		for(my $c=1;$c<=$cnt;$c++) {
			$tmp[$c] =~ s/^\s+|\s+$//;
			if (looks_like_number($tmp[$c])){
				if($vh{"$name-$c"}<abs($tmp[$c])){
					$vh{"$name-$c"}=$tmp[$c];
				}
			}
			else{
				$tmp[$c]=~s/\s+//g;
				$vh{"$name-$c"}.="$tmp[$c]; ";
			}
		}
	}
}
close F1;

$lc=0;
foreach my $ncc (keys %nh){
	$lc++;
	if($lc==1){print $vh{"header"},"\n";}
	elsif($ncc ne ""){
		print "$ncc\t";
		for(my $c=1;$c<=$cnt;$c++){
			print $vh{"$ncc-$c"},"\t";
		}
		print "$nh{$ncc}\n";
	}
}

__END__

perl remove-duplicate-rows.pl /cygdrive/l/Elite/Aida/MM20CL14.txt > /cygdrive/l/Elite/Aida/MM20CL14rd.txt

