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
$seq = "";
while ($line = <FILENAME>) {
	chomp ($line);	
	if ($line =~ /^>/){
          
	    $line =~ s/>//;
	    push(@seqname,$line);
             $cc++;
	    if ($seq ne ""){
	      push(@seq,$seq);
	      $seq = "";
	    }
      } else {
		  $seq=$seq.$line;
      }
}
open (FILE,"6357yorfs.txt") ||
       die "can't open $name: $!";
$no = "";
while ($noline = <FILE>) {
	chomp ($noline);	
	$no=$no.$noline;
}
$lll=@seq;
$cnt=1;
print "\n\nSeqNo.\tSeqNam\tSequence\n\n";
for($e=0;$e<$lll;$e++)
{
$free=@seqname[$e];
$free =~ s/:/ /g;
@done=split(/ /,$free);
$cont=1;
if(@done[$cont]=~/Y/)
{if(@done[$cont+1]=~/Y/)
{
@nodone=split(/"\n"/,$no);
foreach $nodon(@nodone)
{
if($nodon=~/@done[$cont]/)
{
print "$cnt\t";
print "$free\n";
print "@seq[$e]\n";
}
$cnt++;
}
}
}
}
