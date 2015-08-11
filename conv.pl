#!/usr/local/bin/perl -w
use lib '/home/fimm/ii/ash022/bioperl';
use lib '/home/fimm/ii/ash022/bioperl/IO-String';
use Bio::DB::GenBank;
use Bio::SeqIO;
#use Bio::SeqIO; 
use strict;
my $cnt;

while(<>){
        chomp $_;
        my @tmp=split(/\s+/,$_);
        foreach my $n (@tmp){if($n=~/^NC/){$cnt++;conv($n,$cnt);}} 

}

sub conv  {
	my $informat="genbank"; 
	my $outformat="fasta"; 
	my $infile=shift;
	$infile.=".gbk";
	my $count = shift;
	my $outfile=$infile.".fasta"; 
	my $in = Bio::SeqIO->newFh(-file => $infile , -format => $informat); 
	my $out = Bio::SeqIO->newFh(-file => ">$outfile", -format => $outformat); 
	while (<$in>) { print $out $_; $count++; }  
	warn "Translated $count sequences from $informat to $outformat format\n"
}

