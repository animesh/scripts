#!/usr/local/bin/perl
use Math::Complex;
$pi=pi;
$i=sqrt(-1);

$file=shift @ARGV;
chomp $file;

@base=qw/G T A C/;
$base{""}= "0\t0\t\t0\t0";
$base{"G"}="0\t0\t\t0\t1";
$base{"T"}="0\t0\t\t1\t0";
$base{"A"}="0\t1\t\t0\t0";
$base{"C"}="1\t0\t\t0\t0";
$base{"N"}="1\t1\t\t1\t1";




OPENFAS($file);
WRITEFAS();


sub OPENFAS{
	$file = shift;
	open (F, $file) || die "can't open \"$file\": $!";
	$seq="";
	while ($line = <F>) {chomp $line;
		if ($line =~ /^>/){
			push(@seqname,$line);	
			if ($seq ne ""){
				push(@seq,$seq);
						$seq = "";
					}
			}
		 else {$seq=$seq.$line;
			}
	}
	push(@seq,$seq);
	close F;
}




sub WRITEFAS{
	for ($c1=0;$c1<=$#seq;$c1++) {
		$wfile=$file.".$c1".".fas";
		open(FO,">$wfile");
		$sn=@seqname[$c1];
		$se=@seq[$c1];
		$len=length($se);
		print "$sn: $c1\t$len\n";
		@t=split(//,$se);
		for($c3=0;$c3<=$#t;$c3++){
				print FO"$base{@t[$c3]}\t";
		}
                print FO"\n";
		close FO;
	}
}
