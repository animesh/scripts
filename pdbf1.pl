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
$file = shift;
chomp $file;
open (F,$file);
while($l=<F>)
{	
	if($l =~ /^ATOM/){
		$n++;
		@t=split(/\s+/,$l);
		@t[2]=~s/[0-9]|\*//g;
		$ln=length(@t[2]); #print "$ln\n";
		if ($ln == 2) {
			@t[2] = substr(@t[2],0,1);
		}
		print "@t[2] @t[6] @t[7] @t[8]\n";
	}
}
	
