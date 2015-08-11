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
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName MultSeqFile\t\n\n\n";}
$file = shift @ARGV;
open (F, $file) || die "can't open \"$file\": $!";
$seq="";
while ($line = <F>) {
		chomp $line;
		push(@seqname,$line);	
}
close F;

$fp=$file.".cs.txt";
open (FP,">$fp");

for($c1=0;$c1<=$#seqname;$c1++)
	{
		$fftseq=(@seqname[$c1]);@N=split(/\s+/,$fftseq);$NN=(@N);
		if($NN==40){
		print FP"$fftseq\n";
		}
		#print "$NN\n";
	}
