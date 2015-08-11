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
open(F1,"depp1.txt") || die "can't open \"depp1.txt\": $!";
open(F2,"depp2.txt") || die "can't open \"depp2.txt\": $!";
while($l=<F1>){
	@t=split(/ /,$l);
	for($c=0;$c<4;$c++){
		$arr[$c1][$c]=@t[$c]+0;
	}
	$c1++;
}
while($l=<F2>){
	@t=split(/ /,$l);
	for($c=0;$c<=$#t;$c++){
		if(length(@t[$c])==21){
			@t=split(//,$t[$c]);
			for($c=0;$c<20;$c++){
				if(@t[$c] eq "a"){$prod+=$arr[($c+1)][0];}
				if(@t[$c] eq "t"){$prod+=$arr[($c+1)][1];}
				if(@t[$c] eq "g"){$prod+=$arr[($c+1)][2];}
				if(@t[$c] eq "c"){$prod+=$arr[($c+1)][3];}
			}
		last;
		}
	}
	print "Score : $prod\t\t\t$l";
	$prod=0;
}
