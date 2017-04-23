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
open (FILEOUT1, ">>60charfileAC109365.fas");
while ($line = <F1>) {
        chomp ($line);
        if ($line =~ /^>/){
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {
                  $seq=$seq.$line;
      }
}
push(@seq,$seq);
$l1=@seq;
for($cont=0;$cont<=$#seq;$cont++)
{

@seqnew=split(//,$seq[$cont]);
$len=@seqnew;
$rem=$len%60;
print FILEOUT1">@seqname[$cont]\n";
for($cc=0;$cc<$len;$cc=($cc+60))
{
	for($c=$cc;$c<($cc+60);$c++)
	{
	$seq1=$seq1.@seqnew[$c];
	}
print FILEOUT1"$seq1\n";
$seq1="";}
for($c=$cc;$c<=($cc+$rem);$c++)
	{
	$seq1=$seq1.@seqnew[$c];
	}
print FILEOUT1"$seq1\n";
}