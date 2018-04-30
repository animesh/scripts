#!/usr/bin/perl -w
use strict;

my $USAGE = "translate.pl file.fasta [startpos stoppos]\n";

my %codon =
(
  "TTT" => "F", "TTC" => "F", "TTA" => "L", "TTG" => "L",
  "TCT" => "S", "TCC" => "S", "TCA" => "S", "TCG" => "S",
  "TAT" => "Y", "TAC" => "Y", "TAA" => "*", "TAG" => "*",
  "TGT" => "C", "TGC" => "C", "TGA" => "*", "TGG" => "W",
  "CTT" => "L", "CTC" => "L", "CTA" => "L", "CTG" => "L",
  "CCT" => "P", "CCC" => "P", "CCA" => "P", "CCG" => "P",
  "CAT" => "H", "CAC" => "H", "CAA" => "Q", "CAG" => "Q",
  "CGT" => "R", "CGC" => "R", "CGA" => "R", "CGG" => "R",
  "ATT" => "I", "ATC" => "I", "ATA" => "I", "ATG" => "M",
  "ACT" => "T", "ACC" => "T", "ACA" => "T", "ACG" => "T",
  "AAT" => "N", "AAC" => "N", "AAA" => "K", "AAG" => "K",
  "AGT" => "S", "AGC" => "S", "AGA" => "R", "AGG" => "R",
  "GTT" => "V", "GTC" => "V", "GTA" => "V", "GTG" => "V",
  "GCT" => "A", "GCC" => "A", "GCA" => "A", "GCG" => "A",
  "GAT" => "D", "GAC" => "D", "GAA" => "E", "GAG" => "E",
  "GGT" => "G", "GGC" => "G", "GGA" => "G", "GGG" => "G",
);


sub translate
{
  my $seqn = shift;
  my $seq = shift;
  my $start = shift;
  my $end = shift;

  return if !defined $seq;

  $start = 1 if !defined $start;
  $end = length($seq) if !defined $end;
 

  $start--;
  my $nona=$seq=~s/[^A-Z]//g;
  my $s = substr($seq, $start, $end-$start);
  my $l = length ($s);

  my $aaseq;

  for (my $i = 0; $i+2 < $l; $i+=3)
  {
    my $aa = $codon{uc(substr($s, $i, 3))};
    $aaseq .= $aa;
  }

  my $aalen = length($aaseq);
  print "$seqn|$start-$end|proteinLength-$aalen|hanging-",$l%3,"|UTR-$nona|\n$aaseq\n";
}



my $file  = shift @ARGV or die $USAGE;
my $start = shift @ARGV;
my $end   = shift @ARGV;

open FASTA, "< $file" or die "Can't open $file for reading ($!)\n";


my $seq;
my $seqn;
while (<FASTA>){
  chomp;
  if (/^>/){ 
        $seqn=$_; 
	translate($seqn,$seq, $start, $end);
	$seq="";
  }  
  else{
    $seq .= $_;
  }
}

translate($seqn,$seq, $start, $end);



