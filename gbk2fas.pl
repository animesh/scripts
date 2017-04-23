#!/usr/bin/perl
use lib "/scratch/bioperl/";
use Bio::Perl;
use Bio::SeqIO;
use strict;
my $window=35;
my $jump=22;
my $main_file=shift @ARGV;
my $fas_file=$main_file."_in.fasta";
open(FT,">$fas_file");
my ($wseqname,$wseq,$wseqlen)=get_other_source($main_file);
sub get_other_source{
    my $foofile=shift;
    my $seqio_object = Bio::SeqIO->new(-file => $foofile, '-format' => 'GenBank');
    my $seq_object = $seqio_object->next_seq;
    for my $feat_object ($seq_object->get_SeqFeatures) {
		if ($feat_object->primary_tag eq "source") { 
			my $start = $feat_object->location->start;       
			my $end = $feat_object->location->end;
			my $sequence = $feat_object->entire_seq->seq;
			my $length_sequence=length($sequence);
			my $seq_name;
			    for my $tag ($feat_object->get_all_tags) {
				    for my $value ($feat_object->get_tag_values($tag)){
					$seq_name.="$value ";
					}
			    }       
			$seq_name.="$start-$end($length_sequence)";
			$seq_name="$foofile\t".$seq_name;
			print FT">$seq_name\n$sequence\n";
			return ($seq_name,$sequence,$length_sequence);
		}
    }

}
my $sno;
for(my $c=0;$c<$wseqlen;$c+=$jump){
    $sno++;
    #print FT">S.$sno.$wseqname\n";
    #print FT substr($wseq,$c,$window),"\n";
}
close FT;

