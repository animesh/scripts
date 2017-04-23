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

$dispar_start=1000001;
$dispar_end=1018095;
$common="AANV0";
#for($c=$dispar_start;$c<=$dispar_end;$c++){
	for($c=$dispar_start;$c<=$dispar_end;$c++){
	$accession_no=$common.$c;
	my $getseq = new Bio::DB::GenBank;
	my $seqout = new Bio::SeqIO(-format => 'genbank');
	my $seq = $getseq->get_Seq_by_acc($accession_no);
	$seqout->write_seq($seq);
}

#Invaden: AANW01000001:AANW01015173
#Histolytica: AAFB01000001:AAFB01001819