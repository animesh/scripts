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
$amino_acid_order = "ABCDEFGHIKLMNPQRSTVWXYZ";
%h2a = (
	'I'		 => 		4.5,
	'V'		 => 		4.2,
	'L'		 => 		3.8,
	'F'		 => 		2.8,
	'C'		 => 		2.5,
	'M'		 => 		1.9,
	'A'		 => 		1.8,
	'G'		 => 		-0.4,
	'T'		 => 		-0.7,
	'W'		 => 		-0.9,
	'S'		 => 		-0.8,
	'Y'		 => 		-1.3,
	'P'		 => 		-1.6,
	'H'		 => 		-3.2,
	'E'		 => 		-3.5,
	'Q'		 => 		-3.5,
	'D'		 => 		-3.5,
	'N'		 => 		-3.5,
	'K'		 => 		-3.9,
	'R'		 => 		-4.5,
	'B'		 => 		-3.5,
	'Z'		 => 		-3.5,
	'X'		 => 		0,
	'*'		 => 		-4.5,
);
open (F, "$file") || die "can't open \"$file\": $!";
$cnt=0;



sub STDMU{
	my $c3=shift; $temp2=0;$temp4=0;
		for($c2=0;$c2<$cnt;$c2++){
			$temp2+=$h2a{$mat[$c2][$c3]};
		}
		$temp2=$temp2/$c2;
		for($c2=0;$c2<$cnt;$c2++){
			$temp4+=($temp2-$h2a{$mat[$c2][$c3]})**2;
			#print "$h2a{$mat[$c2][$c3]}\t";
		}
		$temp4=sqrt($temp4/$c2);
		return ($temp2,$temp4,$c2);
}

sub STDMUR{
	my $c3=shift; $temp2=0;$temp4=0;
		for($c2=0;$c2<$cnt;$c2++){
			$temp2+=$h2a{$matran[$c2][$c3]};
		}
		$temp2=$temp2/$c2;
		for($c2=0;$c2<$cnt;$c2++){
			$temp4+=($temp2-$h2a{$matran[$c2][$c3]})**2;
			#print "$h2a{$mat[$c2][$c3]}\t";
		}
		$temp4=sqrt($temp4/$c2);
		return ($temp2,$temp4,$c2);
}


sub FYS {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
	$seqret="";
	@tem=@$array;
	for($c3=0;$c3<=$#tem;$c3++){
		$seqret.=@tem[$c3];
	}
	return $seqret;
}

while($l=<F>){
	if($l=~/width/){
			@t=split(/;/,$l);		
			@t=split(/\=/,@t[1]);	
			$width=@t[1]+0;
			#print $width;
	}
	#print "$cnt\t@t[1]\n";
	$l=uc($l);
	chomp ($l);
	@t=split(/\)/,$l);		
	@t=split(/ /,@t[1]);		
	if(length(@t[1])==$width and $l=~/\(/ and $l=~/\)/ and $l=~/[0-9]$/){
		print "@t[1]\t";
		@t=split(//,@t[1]);
		for($c1=0;$c1<=$#t;$c1++){
			$mat[$cnt][$c1]=@t[$c1];
			#print "@t[$c1] ";
		}
		$seqret=FYS(\@t);
		print "$seqret\n";
		for($c1=0;$c1<=$#t;$c1++){
			$matran[$cnt][$c1]=@t[$c1];
			#print "@t[$c1] ";
		}
		#print "$cnt\t$c1\n";
		$cnt++;
	}
	if($l=~/^\/\//){
			for($c1=0;$c1<$width;$c1++){
				print "$c1\t";
				STDMU($c1);$temp10=$temp4;
				print "$temp2\t$temp4\t";
				STDMUR($c1);
				
				($temp6,$temp8,$c2)=($temp2,$temp4,$c2);
				$ratio=$temp10/$temp8;
				print "$temp6\t$temp8\t$ratio\t$c2\n";

			}
			last;
	}
	
}

