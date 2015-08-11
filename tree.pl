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
open(F,"EDNorm.txt");
while($l=<F>){
	chomp $l;
	$l=~s/^\s+//g;
	@t=split(/\s+/,$l);
	$line++;
	$size=(@t);
	if($line==1){print "$size\n";}
	print "org$line\t     ";
		for($c1=0;$c1<=$#t;$c1++){
			$val=@t[$c1]+0; 
			#$val*=1000;$val=int($val);
			$val=sprintf("%.3f", $val);
			print "$val "; 
	}
	print "\n";
}
		
#    5
#Alpha      0.000 1.000 2.000 3.000 3.000
