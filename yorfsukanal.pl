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
open (FILENAME,"6357yorfs.txt") ||
       die "can't open $name: $!";
while ($lin = <FILENAME>) {
if ($lin =~ />/){
print "hi";
push(@seqname,$lin);
}
}
print @seqname;
$lll=@seqname;
$cnt=1;
foreach $free (@seqname)
{
$free =~ s/:/ /g;
@done=split(/ /,$free);
$cont=1;
if(@done[$cont]=~/Y/)
{if(@done[$cont+1]=~/Y/)
{
print "@done[$cont+1]\t@done[$cont]\n";
}
}
$cnt++;
}
