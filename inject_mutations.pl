#!/usr/bin/perl
use strict;

my %t2o = ('ALA' => 'A','VAL' => 'V','LEU' => 'L','ILE' => 'I','PRO' => 'P','TRP' => 'W','PHE' => 'F', 'MET' => 'M','GLY' => 'G','SER' => 'S','THR' => 'T','TYR' => 'Y','CYS' => 'C','ASN' => 'N','GLN' => 'Q','LYS' => 'K','ARG' => 'R','HIS' => 'H','ASP' => 'D','GLU' => 'E',);

my $fasta_file=shift @ARGV;
my $mutation_file=shift @ARGV;

open(F,$fasta_file)||die "can't open";
open(M,$mutation_file)||die "can't open";
my $o="$fasta_file.$mutation_file.fasta";
open(O,">$o")||die "can't open";

my $seq;
my $seqn;
my $seqnc;
my $seqid;
my %seqh;
my %seqnch;

while (my  $line = <F>) {
        chomp $line;
        if($line =~ /^>/){
        	$seqn=$line;
        	my @tmp=split(/\|/,$line);
        	$seqid=$tmp[1];                
                $seqnch{$seqid}.=$seqn;
        }
        else{
                $seqh{$seqid}.=$line;
        }
}

#foreach (keys %seqh){print "$_\t$seqh{$_}\n";}

while (my  $line = <M>) {
        chomp $line;
        my @tmp=split(/\s+/,$line);
                my @tmp2=split(/\./,$tmp[3]);
                my $oaa=substr($tmp2[1],0,3);
        	my $caa=substr($tmp2[1],length($tmp2[1])-3,3);
        	my $pos=substr($tmp2[1],3,length($tmp2[1])-6)+0;
        	my $seqo=$seqh{$tmp[1]};
        	if(($seqo) and ($tmp[1] =~ /^[A-Z]/) and (substr($seqo,$pos-1,1) eq $t2o{uc($oaa)})){
        		substr($seqo,$pos-1,1)= $t2o{uc($caa)};
        		$seqnch{$tmp[1]}=~s/$tmp[1]/$tmp[1]-$tmp2[1]/g;
        		print O"$seqnch{$tmp[1]}\t$line\n$seqo\n";
        	}
        	else{print "No Match:\t$tmp[1]\tPosition-$pos\tOrigAA-$oaa\t$caa\t",length($seqh{$tmp[1]}),"\tMutate-$seqh{$tmp[1]}\t$seqnch{$tmp[1]}\t$line\n"}
}

#print "$se\n";

close F;
close M;
close FO;


__END__

http://www.uniprot.org/docs/humsavar
http://www.uniprot.org/help/batch

 perl inject_mutations.pl fas var | less


