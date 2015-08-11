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
# test_source_gbk.pl     sharma.animesh@gmail.com     2006/09/10 12:14:03

use warnings;
use strict;
$|=1;
use Data::Dumper;
use Bio::SeqIO;
my $file=$ARGV[0];
my $number=1;
get_other_source($file,$number);

my $n_other_source;
my %other_source_sequence_name;
my %other_source_sequence;

sub get_other_source{
    my $foofile=shift;
    my $foofileno=shift;
    my $seqio_object = Bio::SeqIO->new(-file => $foofile, '-format' => 'GenBank');
    my $seq_object = $seqio_object->next_seq;
    print "$foofile\t$foofileno\n";
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
			$n_other_source++;
			$seq_name.="$start-$end($length_sequence)";
			$seq_name="$foofile ($n_other_source)".$seq_name;
			$other_source_sequence_name{$n_other_source}=$seq_name;
			$other_source_sequence{$n_other_source}=$sequence;
		    }
    }
}

foreach (keys %other_source_sequence_name){
    print "$other_source_sequence_name{$_}\n$other_source_sequence{$_}\n";
}
__END__

=head1 NAME

test_source_gbk.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for test_source_gbk.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

Animesh Sharma, E<lt>krishna_bhakt@BHAKTI-YOGAE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Animesh Sharma

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
