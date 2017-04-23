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
# And
#	Invaden: AANW01000001:AANW01015173
#	Just for Info:	Histolytica: AAFB01000001:AAFB01001819
# Avoiding get_Stream_by_batch so that individual file can be written


use Bio::DB::GenBank;
use Bio::SeqIO;
use strict;
my $inputt=shift @ARGV;
for dispar
getGB(1,18095,"AANV010");
for invadens
getGB(1,15173,"AANW010");


sub getGB{
	my $start=shift;
	my $end=shift;
	my $common=shift;
	for(my $c=$start;$c<=$end;$c++){
	#for(my $c=$inputt;$c<=$end;$c++){
	#for(my $c=$start;$c<=$start+3;$c++){
		$c=sprintf('%05d', $c);
		my $accession_no=$common.$c;
		my $fname=$accession_no.".gbk";
		print "Writing $fname\t";
		my $seqout = new Bio::SeqIO( -file => ">$fname" , -format => 'GenBank');
		my $getseq = new Bio::DB::GenBank;
		my $seq = $getseq->get_Seq_by_acc($accession_no);
		$seqout->write_seq($seq);
		print "Done.\n";
	}
}
