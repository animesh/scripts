#!/usr/bin/perl
use strict;
use warnings;
my $f=shift @ARGV;
open (F,$f);
my @motifs=shift;#qw/QK.[ILVAG]..[FY][FY]/;
#my @motifs=qw/QK.[ILVAG]..[FY][FY]/;
#my @motifs=qw/[RKSE]I[QE][REK][NK][KR]..AL.[RL][RL]..[KR]/;
#my @motifs=qw/[LN]...[QVS]..[RKSE]I[QE][REK][NK][KR]..AL.[RL][RL]..[KR]/;
#my @motifs=qw/[ILMN]...[QVS]..[RKSE][ILM][QE].[NK][KR]..A[IL].[RLI][RLI]..[KR]/;#https://febs.onlinelibrary.wiley.com/doi/full/10.1111/febs.12867 
#my $seqcolpos=1;
my $seqcolpos=shift;
my $linum;
while (my $line = <F>) {
	$linum++;
	chomp ($line);
	$line=~s/\r//g;
	if($linum==1){print "$f-$line\tMotif,Position;\tLysine\tMotifs\n";}
	else{
	my @se=split(/\t/,$line);
	print "$line\t";#$se[2]\t$se[3]\t";
	my $cnter=0;
	my $flag=0;
	for(my $motifsc=0;$motifsc<=$#motifs;$motifsc++){
		while($se[$seqcolpos] =~ /($motifs[$motifsc])/gi){
			print "$1,$-[0]-$+[0];";
			pos($se[$seqcolpos]) = $-[0] + 1;
			$cnter++;
			$flag+=()=$1=~/K/g;
			#if($-[0]==$se[2]-1){$flag=1;}
		}
	}
	print "\t$flag\t$cnter\n";
	}
}


__END__

perl fas2tablen.pl /cygdrive/f/promec/FastaDB/uniprot-human-feb15.fasta > /cygdrive/f/promec/Results/Ani/N-terminal-UNG/human.fasta.tab

perl motif.pl /home/animeshs/promec/Animesh/uniprot-gene-ung.tab "[ILMN]...[QVS]..[RKSE][ILM][QE].[NK][KR]..A[IL].[RLI][RLI]..[KR]" 9 

