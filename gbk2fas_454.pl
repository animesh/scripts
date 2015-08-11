#!/usr/bin/perl
use lib "/scratch/bioperl/";
use Bio::Perl;
use Bio::SeqIO;
use strict;
my $coverage=50;
my $window=250;
my $socl=200;
my $eocl=300;

my $jump=5;
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
			return ($seq_name,$sequence,$length_sequence);
			#print FT">$seq_name\n$sequence\n";
		}
    }

}
my $sno;
my $totalcnt=$coverage*$wseqlen/$window;
my $totalalength;

for(my $c=0;$c<$totalcnt;$c++){
   	$sno++;
	my $p1=$socl;
	my $p2=$eocl;
	my $pcl=(rand(1));
	$pcl=int($p1+($p2-$p1)*$pcl);
	my $p=int(rand($wseqlen-$pcl));
	$totalalength+=$pcl;
	my $fracgen=$totalalength/$wseqlen;	
    	print "S#-$sno\tStart-$p\tLength-$pcl\tTC-$totalcnt\tC-$coverage\tFrac-$fracgen\tTL2-$totalalength\n";
        print FT">S.$sno.$wseqname\n";
     	print FT substr($wseq,$p,$pcl),"\n";
	my $fracgen=$totalalength/$wseqlen;	
}
close FT;

