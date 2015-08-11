use strict;
use warnings;
my $f = shift @ARGV;
my $mut = shift @ARGV;
my $seq = shift @ARGV;
open FO,">$f.mutated.txt";
open FT,">$f.true.fasta";
open FF,">$f.false.fasta";

open F,$f;
my $l=0;
while(<F>){
	if($l==0){print FO"Line\tSeqNum\tMatch\tExpectedAA\tPresentAA\tMutate2AA\tMutated\t$_";}
	else{
		my @t=split(/\t/);
		my @n=split(/\./,$t[$mut]);
		my $pt=substr($n[1],0,1);
		my $ct=substr($n[1],-1,1);
		$n[1]=~s/[A-Z]//g;
		my @seqsplit=split(/\;/,$t[$seq]);
		for(my $sqcnt=0;$sqcnt<=$#seqsplit;$sqcnt++){
			my $p=substr($seqsplit[$sqcnt],$n[1]-1,1);
			if($p ne $pt){
				print "$l\t$sqcnt\tFALSE\t$pt\t$p\t$ct\t$seqsplit[$sqcnt]\t$_";
				print FO"$l\t$sqcnt\tFALSE\t$pt\t$p\t$ct\t$seqsplit[$sqcnt]\t$_";
				my $sname="$l\t$sqcnt\tFALSE\t$pt\t$p\t$ct\t$_";
				$sname=~s/\t|$t[$seq]/-/g;
				print FF">$sname$seqsplit[$sqcnt]\n";
			}
			else{
				substr($seqsplit[$sqcnt],$n[1]-1,1)=$ct;
				print FO"$l\t$sqcnt\tTRUE\t$pt\t$p\t$ct\t$seqsplit[$sqcnt]\t$_";
				my $sname="$l\t$sqcnt\tTRUE\t$pt\t$p\t$ct\t$_";
				$sname=~s/\t|$t[$seq]/-/g;
				print FT">$sname$seqsplit[$sqcnt]\n";
			}
		}
	}
	$l++;
}


__END__
perl injectmute.pl /cygdrive/c/Users/animeshs/OneDrive/test2.txt 3 10
