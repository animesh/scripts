use strict;
use warnings;
use Bio::SeqIO;
my $f=shift;
my $ftype=shift;
my $i = new Bio::SeqIO(-file => $f, -format => $ftype);
my $o = new Bio::SeqIO(-file => ">$f.cds.fasta");
my $opep = new Bio::SeqIO(-file => ">$f.pep.fasta");
my $seqno=0;
while( my $s = $i->next_seq ) {
  my @codingseq = grep { $_->primary_tag eq 'CDS' } $s->get_SeqFeatures();
  foreach my $feat ( @codingseq ) {
	#print "ID   ", _id_generation_func($feat), "\n";
  $seqno++;
	#print "$feat\n";
    my $fseq = $feat->spliced_seq;
    $o->write_seq($fseq);
    $opep->write_seq($fseq->translate);
	print ">$seqno-";
   for my $tag ($feat->get_all_tags) {
      print "$tag-";
	if($tag eq "translation"){for my $value ($feat->get_tag_values($tag)) {
         print "\n", $value, "\n";
      }}
      else{for my $value ($feat->get_tag_values($tag)) {
         print "-", $value, "-";
      }}
   }
  }
}
