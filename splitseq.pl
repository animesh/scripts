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
use strict;
use Bio::SeqIO;

my $input_file = shift;
my $input_list=shift;

my $seq_in  = Bio::SeqIO->new( -format => 'fasta',
   -file => $input_file);

# loads the whole file into memory - be careful
# if this is a big file, then this script will
# use a lot of memory

my $seq;
my @seq_array;
while( $seq = $seq_in->next_seq() ) {
   push(@seq_array,$seq);
}

# now do something with these. First sort by length,
# find the average and median lengths and print them out

@seq_array = sort { $a->length <=> $b->length } @seq_array;

my $total = 0;
my $count = 0;
foreach my $seq ( @seq_array ) {
   $total += $seq->length;
   $count++;
}

print "Mean length ",$total/$count," Median ",$seq_array[$count/2]->length,"\n";

