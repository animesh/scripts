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
$seqtoortho{"A"}="0\t0\t0\t1";

$seqtoortho{"T"}="0\t0\t1\t0";
$seqtoortho{"G"}="0\t1\t0\t0";
$seqtoortho{"C"}="1\t0\t0\t0";
$seqtoortho{"-"}="0\t0\t0\t0";
$seqtoortho{"X"}="1\t1\t1\t1";


$seqtoortho{"T"}="0\t0\t0\t0";
$seqtoortho{"G"}="0\t0\t0\t0";
$seqtoortho{"C"}="0\t0\t0\t0";
$seqtoortho{"-"}="0\t0\t0\t0";
$seqtoortho{"X"}="0\t0\t0\t0";

while ($line = <F>) {chomp $line;
	if ($line =~ /^>/){
		$line=~s/\|/\-/g; $line=~s/\s+/-/g;
		push(@seqname,$line);	
		if ($seq ne ""){
			push(@seq,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq,$seq);
close F;
$foo=$file.".out";
open(FO,">$foo");
for($c1=0;$c1<=$#seq;$c1++){
	$sname=@seqname[$c1];
	$sequences=@seq[$c1];
	$sequences=~s/\s+//g;
	$sequences=~s/[0-9]//g; 
	$sequences=~s/\*//g;
	$len=length($sequences);
	print "$sequences\t$len\n";
	@temp=split(//,$sequences);
	for($c2=0;$c2<=$#temp;$c2++){
		print FO"$seqtoortho{@temp[$c2]}\t";
	}
	#print FO"1\t0\t0\n";
}
#clustalw file /output=pir
#perl rfas.pl file.pir
