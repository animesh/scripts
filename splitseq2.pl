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

$input_file = shift @ARGV;
$input_list=shift @ARGV;
open(FL,$input_list);
while($l=<FL>){
	chomp $l;
	if($l ne ""){
		my @t=split(/\t/,$l);
		my $name=@t[0];
		$name=~s/\s+/_/g;
		push(@names,$name);
		@t=split(/\,/,@t[1]);
		foreach  (@t) {
			my $sn="S".$_;
			push(@$name,$sn);
			print $sn;
		}
	}
}
close FL;
foreach $filename (@names) {
	$fn=$filename.".txt";
	open(FO,">$fn");
	foreach $seqn (@$filename) {
		$seq_in  = Bio::SeqIO->new( -format => 'fasta', -file => $input_file);
		while( $seq = $seq_in->next_seq() ) {
			$seqname=$seq->id;
			$seqtext=$seq->seq;
			if($seqn eq $seqname){
				print FO">$seqname\n$seqtext\n";
				$match{$seqn}++;
			}
		}
	}
	close FO;
}

$fn="rest_of_$input_list.txt";
open(FO,">$fn");
$seq_in  = Bio::SeqIO->new( -format => 'fasta', -file => $input_file);
while( $seq = $seq_in->next_seq() ) {
	$seqname=$seq->id;
	$seqtext=$seq->seq;
	if(!$match{$seqname}){
		print $seqname;
		print FO">$seqname\n$seqtext\n";
	}
}
close FO;