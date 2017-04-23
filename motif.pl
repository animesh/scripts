#!/usr/bin/perl
use strict;
use warnings;
my $f=shift @ARGV;
my @pip=qw/QK.[ILVAG]..[FY][FY]/;
open (F,$f);
print $f;
print "SeqName\tPosition(s)\tPTM\tMotif(s)\tFlag\tTotal\n";
while (my $line = <F>) {
	chomp ($line);
	$line=~s/\r//g;
	my @se=split(/\t/,$line);
	print "$se[0]\t$se[2]\t$se[3]\t";
	my $cnter=0;
	my $flag=0;
	for(my $pipc=0;$pipc<=$#pip;$pipc++){
		while($se[1] =~ /($pip[$pipc])/gi){
			print "$1,$-[0]-$+[0];";
			pos($se[1]) = $-[0] + 1;
			$cnter++;
			$flag+=()=$1=~/K/g;
			#if($-[0]==$se[2]-1){$flag=1;}
		}
	}
	print "\t$flag\t$cnter\n";
}


__END__

perl fas2tablen.pl /cygdrive/f/promec/FastaDB/uniprot-human-feb15.fasta > /cygdrive/f/promec/Results/Ani/N-terminal-UNG/human.fasta.tab
perl motif.pl /cygdrive/f/promec/Results/Ani/N-terminal-UNG/Acetylation.elm > /cygdrive/f/promec/Results/Ani/N-terminal-UNG/Acetylation.elm.pos.txt
