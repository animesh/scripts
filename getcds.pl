#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/bin/perl
use Bio::SeqIO;
use strict;
my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;

my $total_file_name=$main_file_pattern.".cds.fasta";

open(FT,">temp.txt");
open(FTTL,">$total_file_name");
my $n_gene_threshold; 
my $file;
my $n_gene;


system("ls -1 $main_file_pattern*.gb* > tempfile1");
open(FT1,"tempfile1");
my $tfl1;
while($tfl1=<FT1>){
    $n_gene++;
    chomp $tfl1;
    my $file=get_main_source($tfl1);
    print "$tfl1: Total Gene, $n_gene\n";
    print FT"$tfl1: Total Gene, $n_gene out of $n_gene_threshold $file\n";

}
close FT1;
close(FTTL);

sub get_main_source{
    my $gb_file=shift;
    my $seqio_object = Bio::SeqIO->new(-file => $gb_file, '-format' => 'GenBank');
    my $seq_object = $seqio_object->next_seq;
    for my $feat_object ($seq_object->get_SeqFeatures) {
	if ($feat_object->primary_tag eq "CDS") { 
	    #if ($feat_object->primary_tag eq "gene") { 
	    my $start = $feat_object->location->start;       
	    my $end = $feat_object->location->end;
	    my $strand = $feat_object->location->strand;$strand+=0;
	    my $seq = $feat_object->spliced_seq->seq;
	    my $sequence_string = $feat_object->entire_seq->seq;
	    my $seq_utr;my $seq_tag;my $seq_dutr;
	    my $l_seq_complete=length($sequence_string);
	    my $l_seq=length($seq);
	    my $seq_name;
	    my $al_utr;
	    my $al_dutr;
	    my @product_name=$feat_object->get_tag_values('product');
	    if(@product_name[0]=~/hypothetical/){
		next;
	    }
	    for my $tag ($feat_object->get_all_tags) {
		if(($tag eq "translation") or ($tag eq "codon_start")){
		    next;
		}
		else{
		    for my $value ($feat_object->get_tag_values($tag)){
			$seq_name.="$value ";
		    }
		}
	    }
	    print FTTL">$gb_file:\t$seq_name\n$seq\n"
	}
    }
    print "\n";
}

