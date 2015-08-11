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
open (FILE,"ukyeastgenes.txt") ||
       die "can't open $name: $!";
while ($noline = <FILE>) {
	chomp ($noline);	
	$no=$no." ".$noline;
}
open (FILEY,"yt.txt") ||
       die "can't open $name: $!";
while ($nnoline = <FILEY>) {
	chomp ($nnoline);	
	$nno=$nno." ".$nnoline;
}
chomp ($no);
chomp ($nno);
@nodone=split(/ /,$no);
@nnodone=split(/ /,$nno);
$c=@nodone;
$cc=@nnodone;
$cont=1;
foreach $test (@nnodone) {
	$test=~s/,//g;
}
$cc=0;
foreach $t (@nodone) {
foreach $tt (@nnodone) {
		$t=~s/$tt//;
	}
	print "> $cc $t\n";
	$cc++;
}
