#!/usr/bin/perl -w

use Bio::Seq;
use Bio::Index::Fasta;
$out = Bio::SeqIO->new(-file => ">>seq" , '-format' => 'Fasta');
print "File with list of genescan identified genes? ";		
$filename = <STDIN>;
open (FILENAME,$filename) || die " cannot open $filename: $!";

$dir="/home/andrew/exhome";
$db="eh2x";
$dbobj = Bio::Index::Abstract->new("$dir/$db");
while ($gene_seq =<FILENAME>) {
	chomp ($gene_seq);
	$gene_seq =~ s/pfcon-//; #remove header
	($start,$end,$name) = split /-/,$gene_seq;
	print "$start $end $name\n";
	$end = $start + $end;
	$name =~ s/cn_//;
	$name =~ s/ .*//;
	$id = $name;
	print "\n$name\n$start $end\n\n";
$seq=();

$seq = $dbobj->get_Seq_by_id($id);

$len = $seq->length();
print "$id\t$len\n";
$out->write_seq($seq);
}