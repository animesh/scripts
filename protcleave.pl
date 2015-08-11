#!/usr/bin/perl
use strict;
use warnings;

my $f1=shift @ARGV;chomp $f1;
my $thr=shift @ARGV;
my %seqh;
my $seqc;

open F1,$f1||die"\nUSAGE:	\'perl program_name filename_2B_scanned\'\n\n";

while(my $l1=<F1>){
	$l1=~s/\r|\n|$//g;
	if($l1!~/^>/){
		$seqh{$seqc}.=$l1;		
	}
	else{$l1=~s/\>|sp\|//g;$seqc=$l1;}
}

foreach (keys %seqh){
	my $seqn=$_;
	my $seq=$seqh{$_};
	my $lgt=length($seq);
	my $chg=0;
	if(!$thr){$chg=1;$thr=$lgt;}
	for(my $c2=0;$c2<$thr;$c2++){
		my $protstr=substr($seq,$c2,$lgt);
		if($protstr ne ""){print ">sp|S$c2$seqn\n$protstr\n";}
	}
	if($chg==1){undef $thr;}
}


__END__

perl protcleave.pl /cygdrive/X/FastaDB/ntungintein.fasta | wc # as length calculator ;)
