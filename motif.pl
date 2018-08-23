#!/usr/bin/perl
use strict;
use warnings;
my $f=shift @ARGV;
my $motif=shift;#qw/[ILMN]...[QVS]..[RKSE][ILM][QE].[NK][KR]..A[IL].[RLI][RLI]..[KR]/;#https://febs.onlinelibrary.wiley.com/doi/full/10.1111/febs.12867
my $seqn="";
my $seq="";
my $cnt=0;

sub motifind {
	my $flag=0;
	my $seql=shift;
	my $motf="";
	while($seql =~ /($motif)/gi){
		$motf.="$1,$-[0]-$+[0];";
		pos($seql) = $-[0] + 1;
		$flag+=()=$1=~/$motif/g;
	}
	$motf.="\t$flag";
	return $motf;
}

print "Name\tMotif(s),Position(s);\tTotalMotifs\tSequenceLines\n";
open (F,$f);
while (my $line = <F>) {
	$line =~ s/[\r\n]+$//;
	if($line=~/^>/){
		if($seq ne ""){print motifind($seq),"\t",$cnt,"\n";}
		$seqn=$line;
		$cnt=0;
		$seq="";
	}
	else{
		if($cnt==0){print "$seqn\t";}
		$line =~ s/[^a-zA-Z0-9,]//g;
		$seq.=$line;
		$cnt++;
	}
}
close F;
