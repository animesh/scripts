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
open F1,"ricecontigAC109365.fas";
open (FILEOUT1, ">AC109365.fas.1");
open (FILEOUT2, ">AC109365.fas.2");
while($l=<F1>)
{
chomp($l);
$li=$li.$l;
}
@seq=split(//,$li);
$len=@seq;
print "$len";
#for($c=0;$c<=($len/2+100);$c++)
#{$seq1=$seq1.@seq[$c];}
#for($cc=($len/2-100);$cc<=$len;$cc++)
#{$seq2=$seq2.@seq[$cc];}
#print FILEOUT1"$seq1";
#print FILEOUT2"$seq2";

