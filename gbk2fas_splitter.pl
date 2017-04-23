#    This program is free software: you can redistribute it and/or modify
#    #    it under the terms of the GNU General Public License as published by
#    #    the Free Software Foundation, either version 3 of the License, or
#    #    (at your option) any later version.
#    #
#    #    This program is distributed in the hope that it will be useful,
#    #    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    #    GNU General Public License for more details.
#    #
#    #    You should have received a copy of the GNU General Public License
#    #    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#    #
#    #    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]
#    #!/usr/bin/perl
use lib "/Home/siv11/ash022/bioperl/";
use Bio::Perl;
use Bio::SeqIO;
use strict;


my $main_file=shift @ARGV;
my $window=shift @ARGV;
my $jump=shift @ARGV;

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
for(my $c=0;$c<$wseqlen;$c+=$jump){
    $sno++;
    print FT">S.$sno.$wseqname\n";
    print FT substr($wseq,$c,$window),"\n";
}
close FT;

