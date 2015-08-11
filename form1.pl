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
if (!$f1) {print "\nUSAGE:	\'perl program_name filename_2_b_transposed\'\n\n";exit;}
open F1,$f1||die"cannot open $f1";
$c=0;
while($l1=<F1>){
	chomp $l1;	$c++;
	if($c==1){next;}
	else{
	@t1=split(/\t/,$l1);
	for($c2=3;$c2<=$#t1;$c2++){@t1[$c2]=@t1[$c2]+0;
		print "@t1[$c2]\t";
		}
	print "\n";
	}
}
close F1;