my $f1 = shift @ARGV;
open (F1, $f1) || die "can't open \"$f1\": $!";
use strict;
use Text::ParseWords;
my %nh;
my %ph;
my $cntt;
my $thr=0.05;

while (my $line = <F1>) {
	$line =~ s/\r//g;
	chomp $line;
	my @tmp=parse_line('\t',0,$line);
	my @tmpp=split(/-/,$tmp[0]);
	if($tmp[2]<$thr){
		$nh{$tmpp[1]}++;
		$ph{$tmpp[1]}.="$tmp[0]-$tmp[1]-$tmp[2]\t";
	}
}
close F1;

print "Codon\tCount\tPositions\n";
foreach my $ncc (keys %nh){
	if($nh{$ncc}>0){
		print "$ncc\t$nh{$ncc}\t$ph{$ncc}\n";
	}
}

__END__

 perl expand-maxquant-gene.pl /cygdrive/l/Elite/LARS/2014/januar/SILAC\ 2ndparalell/MQcombo.txt > /cygdrive/l/Elite/LARS/2014/januar/SILAC\ 2ndparalell/MQcomboGN.csv