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

#!usr/bin/perl
print "Enter the file name containing sequences: ";
$file=<>;
open (FILE, "$file")||
die "can't open the file $!: ";
while ($fname=<FILE>)
{
chomp $fname;
if ($fname=~ /^>/)
{
$fname=~ s/>//;
push (@sname,$fname);
}
else
{
push (@seq,$fname);
}
}
$len=@seq;
for ($i=0;$i<$len;$i++)
{
for ($j=0;$j<$len;$j++)
{
$sc=0;
@seq1=split (//,@seq[$i]);
@seq2=split (//,@seq[$j]);
$le=@seq1;
for ($k=0;$k<$le;$k++)
{
if (@seq1[$k] eq @seq2[$k])
{
$sc=$sc+0;
}
else
{
$sc=$sc+1;
}
}
$sm[$i][$j]=$sm1[$i][$j]=$sc;
}
}


for ($i=0;$i<$len;$i++)
{
for ($j=0;$j<$len;$j++)
{
$sum1=0;
$sum2=0;
for ($k=0;$k<$len;$k++)
{
if ($i!=$j && $i!=$k && $j!=$k)
{
$sum1=$sum1+$sm[$i][$k];
$sum2=$sum2+$sm[$j][$k];
}
}
$sum=$sm[$i][$j]-($sum1/($len-2))-($sum2/($len-2));
$sum1[$i][$j]=abs ($sum);
}
}
for ($i=0;$i<$len;$i++)
{
for ($j=0;$j<$len;$j++)
{
printf ("%.2f\t",$sum1[$i][$j]);
}
print "\n";
}