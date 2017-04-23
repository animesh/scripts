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

#!/usr/bin/perl -w

use Bio::SeqIO;
use Bio::DB::GenBank;

$genBank = new Bio::DB::GenBank;  # This object knows how to talk to GenBank

my $seq = $genBank->get_Seq_by_acc('AF060485');  # get a record by accession 

my $seqOut = new Bio::SeqIO(-format => 'genbank');

$seqOut->write_seq($seq);

#print $seqOut;
