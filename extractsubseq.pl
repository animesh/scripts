#!/usr/bin/perl
use strict;

my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
my $start=shift @ARGV;
my $end=shift @ARGV;

open(F,$main_file_pattern)||die "can't open";
my $fo=$main_file_pattern.".$start.$end.fasta";
open(FO,">$fo")||die "can't open";

my $seq;
my $seqn;
while (my  $line = <F>) {
 	chomp $line;
        if($line =~ /^>/){
                $seqn.=$line;
      	} 
      	else{
      		$seq.=$line;
      	}
}

print FO"$seqn\t$start-$end\n",substr($seq,$start-1,$end-$start+1),"\n";
      	
close F;
close FO;


__END__ 

perl /cygdrive/c/Users/animeshs/misccb/atacParse.pl /home/animeshs/animeshs/gencomp/atac/NC_007606.NC_013364.atac/NC_007606vsNC_013364.ref\=NC_013364.clumpCost\=5000.atac

perl /cygdrive/c/Users/animeshs/misccb/extractsubseq.pl /home/animeshs/animeshs/gencomp/NC_013364.1.fasta 1 5595
perl /cygdrive/c/Users/animeshs/misccb/extractsubseq.pl /home/animeshs/animeshs/gencomp/NC_007606.1.fasta 1 5595

cat /home/animeshs/animeshs/gencomp/*5?95*  > /home/animeshs/animeshs/gencomp/5595.fas

/home/animeshs/animeshs/SkyDrive/muscle3.8.31/src/muscle.exe -clwstrict -in /home/animeshs/animeshs/gencomp/5595.fas
