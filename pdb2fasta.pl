#!/usr/local/bin/perl
use strict;
# Separating  Chain from given a PDB file (Sequence and Structure)
my $file=shift @ARGV;
my $col=shift @ARGV;
my $chain=shift @ARGV;

my %t2o = (
      'ALA' => 'A',
      'VAL' => 'V',
      'LEU' => 'L',
      'ILE' => 'I',
      'PRO' => 'P',
      'TRP' => 'W',
      'PHE' => 'F',
      'MET' => 'M',
      'GLY' => 'G',
      'SER' => 'S',
      'THR' => 'T',
      'TYR' => 'Y',
      'CYS' => 'C',
      'ASN' => 'N',
      'GLN' => 'Q',
      'LYS' => 'K',
      'ARG' => 'R',
      'HIS' => 'H',
      'ASP' => 'D',
      'GLU' => 'E',
    );
open(F,$file);
my $l=0;
my %aa;
while(<F>){
	$l++;
	my @t=split(/\s+/);
	for(my $c=0;$c<=$#t;$c++){
		if($c+1==$col && $t[0] eq "ATOM"){
			#print "$l\t$c\t$t2o{$t[$c]}\n";
			$aa{$t[$col]}=$t2o{$t[$c]};			
		}
	}
}
foreach(sort { $a <=> $b } keys(%aa)){
	print "$aa{$_}";
}
