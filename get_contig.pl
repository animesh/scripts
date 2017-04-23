#!/usr/bin/perl -w

use Bio::Seq;
use Bio::Index::Fasta;
$out = Bio::SeqIO->new(-file => ">>seq" , '-format' => 'Fasta');
print "File with list of contig_names? ";		
$filename = <STDIN>;
open (FILENAME,$filename) || die " cannot open $filename: $!";

$dir=".";
$db="eh2x";
$dbobj = Bio::Index::Abstract->new("$dir/$db");
@params = ('database' => 'eh2x','F' => 'F', 'p' => 'blastn',
           '_READMETHOD' => 'Blast');
$factory = Bio::Tools::Run::StandAloneBlast->new(@params);
while ($gene_seq =<FILENAME>) {
	chomp ($gene_seq);
        $gene_seq =~ s/>//;
        $gene_seq =~ s/ .*//;
        $id = $gene_seq;
	print "\n$id\n\n";
$seq=();

$seq = $dbobj->get_Seq_by_id($id);
#$len = $seq->length();
#print "$id\t$len\n";
#$out->write_seq($seq);
$outfile = $id.'blast';
$factory->o($outfile);
$factory->blastall($seq);
}
