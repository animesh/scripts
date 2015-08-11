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
# Modified by sharma.animesh@gmail.com using
#
#		"How to retrieve GenBank entries over the Web"
#	
#										by Jason Stajich
#
# To download E. dispar WGS sequence from AANV01000001 to AANV01018095

use Bio::DB::GenBank;
use Bio::SeqIO;
my $gb = new Bio::DB::GenBank;
$dispar_start=1000001;
$dispar_end=1018095;
$common="AANV0";


my $seqout = new Bio::SeqIO( -file => '>test.gbk' , -format => 'GenBank');

# if you want a single seq
#my $seq = $gb->get_Seq_by_id('MUSIGHBA1');
#$seqout->write_seq($seq);
# or by accession
$seq = $gb->get_Seq_by_acc('AF303112');

$seqout->write_seq($seq);

# if you want to get a bunch of sequences use the batch method
#my $seqio = $gb->get_Stream_by_batch([ qw(J00522 AF303112 2981014)]); 

#while( defined ($seq = $seqio->next_seq )) {
#        $seqout->write_seq($seq);
#}
