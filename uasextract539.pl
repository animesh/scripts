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
open (FILENAME1,"539gcn4p.txt") ||
       die "can't open file1: $!";
while ($line1 = <FILENAME1>) {
chomp ($line1);
push(@name,$line1);
}
open (FILENAME2,"UASorfsyeast.txt") ||
       die "can't open file2: $!";
while($line2 = <FILENAME2>)
{
chomp ($line2);
if($line2=~/^>/)
{
$line2=~s/>//;
print "$line2\n";
push(@seqname,$line2);
}
}

















#foreach (@seqname){print "$_\n";}
