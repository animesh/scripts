my $f1 = shift @ARGV;
open (F1, $f1) || die "can't open \"$f1\": $!";
use strict;
use Text::ParseWords;
my %nh;
my %ph;
my $cntt;
my $lc;
my $header;

while (my $line = <F1>) {
	$line =~ s/\r//g;
	$lc++;
	chomp $line;
	if($lc==1){$header=$line;}
	else{
		my @tmp=parse_line('\t',0,$line);
		my @tmpp=split(/-/,$tmp[0]);
		my $aa=substr($tmpp[1],0,3);
		$nh{$aa}++;
		for(my $c=1;$c<=$#tmp;$c++){
			$ph{"$aa-$c"}+=$tmp[$c];
		}
	}
}
close F1;

print "$header\tCount\n";
my @tmp=parse_line('\t',0,$header);
foreach my $ncc (keys %nh){
		print "$ncc\t";
		for(my $c=1;$c<=$#tmp;$c++){
			print $ph{"$ncc-$c"},"\t";
		}
		print "$nh{$ncc}\n";
}


__END__

 perl expand-maxquant-gene.pl /cygdrive/l/Elite/LARS/2014/januar/SILAC\ 2ndparalell/MQcombo.txt > /cygdrive/l/Elite/LARS/2014/januar/SILAC\ 2ndparalell/MQcomboGN.csv