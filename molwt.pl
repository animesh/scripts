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
%molwt = qw/a 1 t 2 g 3 c 4/;
@aa = qw/a t g c/;
print "do u want to enter a file name(y/n)?";
$case=<STDIN>;
chomp $case;
if($case eq 'y')
{
print "enter the name of the file";
$file=<STDIN>;
open ( FILE, $file)|| die "can not open the file $file
$!";
while($line=<FILE>)
{
chomp$line;
if($line=~/>/)
{
$line=~s/>//;
$seq=$line;
}
else
{
$seq=$seq.$line;
}
}
print "the sequence name is $seq\n";
}
else
{
print "enter the sequence>";
$seq=<STDIN>;
print "$seq";
}
$mw = 0;
foreach $res(@aa)
{
$noofres = $seq =~ s/$res//g;
$mw = $mw + ($noofres*($molwt{$res}));
}
print "the mol wt of the seq is $mw.\n ";




