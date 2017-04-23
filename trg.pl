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
if (!$f1) {print "\nUSAGE:	\'perl program_name filename_2_b_transposed'\n\n";exit;}
open F1,$f1||die"cannot open $f1";
my $c1=0;
while($l1=<F1>){
	chomp $l1;
	@t1=split(/\s+/,$l1);
	for($c2=0;$c2<=$#t1;$c2++){
		(@t1[$c2])=~s/\s+//;
		$mat[$c2][$c1]=(@t1[$c2]);
		}
	
	$c1++;
}
for($c5=0;$c5<$c2;$c5++){
	for($c6=0;$c6<($c1-1);$c6++){
		print "$mat[$c5][$c6]\t";
		}
	print "$mat[$c5][$c6]\n";
}
