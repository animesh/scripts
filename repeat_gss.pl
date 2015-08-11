#!/usr/bin/perl -w
use Bio::Seq;
use Bio::Index::Fasta;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Tools::BPlite;
#$out = Bio::SeqIO->new(-file => ">>seq" , '-format' => 'Fasta');
my (@hits,@seqname,@repname);
print "File with list of contig_names? ";		
$filename = <STDIN>;
open (FILENAME,$filename) || die " cannot open $filename: $!";
print " O/P filename? ";
$out = <STDIN>;
chomp $out;
open (OUT,">$out") || die " cannot open $out: $!";
$dir=".";
$db="eh_gss";
$dbobj = Bio::Index::Abstract->new("$dir/$db");
@params = ('database' => 'eh_gss','F' => 'F', 'p' => 'blastn',
           'e'=> 0.1, 'b'=> 10000);
# this is to be added if the Blast.pm is used  '_READMETHOD' => 'Blast');
$factory = Bio::Tools::Run::StandAloneBlast->new(@params);
#
# reading sequence names from file
#
while ($gene_seq =<FILENAME>) {           #l1
	chomp ($gene_seq);
        $gene_seq =~ s/>//;
        $gene_seq =~ s/ .*//;
        $id = $gene_seq;
	print "\n$id\n\n";
        if ($id eq "end"){
        close OUT;
        close FILENAME;
        die "Program ended"
        }
#
#check if sequence already present
#
  $joinhits = join ' ',@seqname;
  if ($joinhits !~ $id) {                  #l2

# if not...getting query sequence from database
#
# and blasting
@hits=();
$seq=();
$seq = $dbobj->get_Seq_by_id($id);
#$len = $seq->length();
#print "$id\t$len\n";
#$out->write_seq($seq);
#$outfile = $id.'blast';
#$factory->o($outfile);
my $report = $factory->blastall($seq);

#
# parsing to see if sequence has any hits repeated
#
#
push @hits, $id; #$report->query;
#$report->database;
while(my $sbjct = $report->nextSbjct) {   #l3
   my $name = $sbjct->name;
   $name =~ s/ .*//;
#   print "$name name\n";
    while (my $hsp = $sbjct->nextHSP) {   #l4
#        $hsp->score;
#        $hsp->bits;
        $percent=$hsp->percent;
#        $hsp->P;
#        $hsp->match;
#        $hsp->positive;
        $length=$hsp->length;
#        $qseq=$hsp->querySeq;
#       $sseq=$hsp->sbjctSeq;
#        $hsp->homologySeq;
#        $qs=$hsp->query->start;
#        $qe=$hsp->query->end;
#        $ss=$hsp->subject->start;
#        $se=$hsp->subject->end;
#        $hsp->subject->seqname;
#        $hsp->subject->overlaps($exon);

# if a stretch larger than 200bp is repeated with 90% accuracy
if ($length > 199 and $percent >= 80) {   #l5
#and if it is not already part of the hits list
$joinhits = join ' ',@hits;
if ($joinhits !~ $name) {                  #l6
#storing hit name in array
#print $name;
push @hits, $name;
}}}}                                       #el3,4,5,6
#completed blast report
# and if hits in this are more than 5 then add to array
if ($#hits >=4) {
push @repname, [@hits];
push @seqname, @hits;
if ($#hits > 49) {
$hitname = join ', ',@hits;
print "@hits \n";
print OUT "No of hits = $#hits \n";
print OUT "$hitname \n\n";
}}}
}                                         #el1,2,7,8

