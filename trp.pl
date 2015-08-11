#!/usr/bin/perl
use strict;
use warnings;
use Text::ParseWords;

my $f1=shift @ARGV;chomp $f1;
my $thr=shift @ARGV;chomp $thr;
if (!$f1) {print "\nUSAGE:	\'perl program_name filename_2_b_transposed\'\n\n";exit;}
open F1,$f1||die"cannot open $f1";
my $c1=0;
my $c2;
my $c6;
my @mat;

while(my $l1=<F1>){
	chomp $l1;
	$l1 =~ s/\r//g;
	my @t1=parse_line(',',0,$l1); #split(/\,/,$l1);
	for($c2=0;$c2<=$#t1;$c2++){
		$mat[$c2][$c1]=$t1[$c2];
	}
	$c1++;
}

for(my $c5=0;$c5<$c2;$c5++){
	for($c6=0;$c6<$c1-1;$c6++){
		if($thr eq ""){print "$mat[$c5][$c6],";}
		elsif($mat[$c5][$c6]=~/NaN/ and $thr>0){print "NaN,";}
		elsif($mat[$c5][$c6]=~/[A-Z]/i){print "$mat[$c5][$c6],";}
		elsif($mat[$c5][$c6]>=$thr||$mat[$c5][$c6]<=(1/$thr)){print $mat[$c5][$c6]+0,",";}
		else{print ",";}
	}
	print "$mat[$c5][$c6]\n";
}

__END__

perl trp.pl /cygdrive/c/Users/animeshs/Desktop/SS1RPGparse.csv 2 2>0 > /cygdrive/c/Users/animeshs/Desktop/SS1RPGparsetranspose.csv
