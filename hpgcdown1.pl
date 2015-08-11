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

$fs = shift @ARGV;
open F,$fs;
while($l = <F>){
	chomp $l;
	@temp=split(/\s+/,$l);
	#foreach (@temp) {print "$_\t";}print "\n";
	if(@temp[2] ne ""){
	push(@list,(@temp[2]));}
	}
	#print @list;
close F;

