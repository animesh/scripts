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

#!/usr/local/bin/perl -w
use strict;

use Bio::Tools::GFF;
use Bio::SeqIO;

my ($seqfile) = @ARGV;
die("must define a valid seqfile to read") unless ( defined $seqfile && -r $seqfile);

my $seqio = new Bio::SeqIO(-format => 'genbank',
			   -file   => $seqfile);
my $count = 0;
while( my $seq = $seqio->next_seq ) {
    $count++;
    # defined a default name
    my $fname = sprintf("%s.gff", $seq->display_id || "seq-$count");
    my $gffout = new Bio::Tools::GFF(-file => ">$fname" ,
				     -gff_version => 1);
    
    foreach my $feature ( $seq->top_SeqFeatures() ) {
	$gffout->write_feature($feature);
    }
}
