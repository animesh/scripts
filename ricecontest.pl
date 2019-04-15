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
print "File containing sequence names? ";
chomp ($file = <STDIN>);
open (FILEIN,"$file");
open(FILEOUT,">ricecont.bat");
while (chomp ($seq = <FILEIN>) )
{
$sout=$seq.".html";
print FILEOUT"/home/andrew/ani/blastcl3 -p blastn -d est -i $seq -o $sout -T\n";
}
