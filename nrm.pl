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
$f1=shift @ARGV;chomp $f1;
if (!$f1) {print "\nUSAGE:	\'perl program_name filename_2_b_normalised\'\n\n";exit;}
open F1,$f1||die"cannot open $f1";
my $c1=0;
while($l1=<F1>){$mean=0;
	if($c1==0){print $l1;}
	else{
	chomp $l1;
	@t1=split(/\t/,$l1);
	
	$max=@t1[1];$min=@t1[1];
	for($c2=1;$c2<=$#t1;$c2++){
		if(@t1[($c2)]>$max){$max=@t1[$c2];}
		if(@t1[($c2)]<$min){$min=@t1[$c2];}
		$mean+=@t1[$c2];
		}
		print "@t1[0]\t";
	for($c2=1;$c2<=$#t1;$c2++){
		if($min==$max){@t1[$c2]=1;}
		else{$mat[$c2][$c1]=(@t1[$c2]-$mean;#print "@t1[$c2]  ";
		@t1[($c2)]=(@t1[$c2]-$mean;}
		print "@t1[($c2)]\t";
		}
	print "\n";
	}
	$c1++;

}