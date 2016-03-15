use strict;
use Text::ParseWords;
use Scalar::Util qw(looks_like_number);
my %vh;
my %nh;
my $cnt=0;

my $f1 = shift @ARGV;
my $idc=shift @ARGV;

open (F1, $f1) || die "can't open \"$f1\": $!";
my $lc;
while (my $line = <F1>) {
	$lc++;
	$line =~ s/\r//g;
	$line=~s/\'/-prime-/g;
	chomp $line;
	my @tmp=parse_line('\t',0,$line);
	if($lc==1){$cnt=$#tmp;$vh{"header"}="$tmp[$idc]\t$line\tColNum$cnt";}
	else{
		my $name=uc($tmp[$idc]);
		my @namez=split(/,/,$name);
		foreach $name (@namez){
			$name =~ s/\s+//g;
			$name =~ s/\W//g;
			$nh{$name}++;
			for(my $c=0;$c<=$cnt;$c++) {
				if ($c!=$idc and looks_like_number($tmp[$c])){
					if(abs($vh{"$name-$c"})<abs($tmp[$c])){
						$vh{"$name-$c"}=$tmp[$c];
					}
				}
				elsif($tmp[$c] ne ""){
					$vh{"$name-$c"}.="$tmp[$c];";
				}
			}
		}
	}
}
close F1;

print $vh{"header"},"\n";
foreach my $ncc (keys %nh){
		print "$ncc\t";
		for(my $c=0;$c<=$cnt;$c++){
			print $vh{"$ncc-$c"},"\t";
		}
		print "$nh{$ncc}\n";
}

__END__

perl remove-duplicate-rows.pl /cygdrive/l/Elite/Aida/MM20CL14.txt > /cygdrive/l/Elite/Aida/MM20CL14rd.txt

