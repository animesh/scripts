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
$file=shift @ARGV;
@class=qw/117 238 125 94 32 48 138 299 146 268 286 110 39 228 155 279 164 204 13 193 215 85 20 0 55 257 247/;
for($c3=0;$c3<=$#class;$c3++){
	open(F,$file);
	while($l=<F>){
	chomp $l;
	@t=split(/\t/,$l);
	@t=split(/\_/,@t[2]);
		if(@class[$c3] == @t[3]){
			#print "@class[$c3] eq @t[3]\t$l\n";
			push(@sf,@t[0]);
			$c1++;
		}
		if($c1 > 2){
			$c1=0;close F;last;
		}
	}		
}
foreach  (@sf) {
	if($_<8400){
	print "$_\n";
	}
}