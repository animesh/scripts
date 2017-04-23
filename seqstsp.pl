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
$file = shift @ARGV;
$cp=0;$cnp=0;
open(F,$file);
$seq="";while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             push(@seqname,$line);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);
for($c=0;$c<=$#seq;$c++)
	{
	$sseq=@seq[$c];
	$snam=@seqname[$c];
	$slen=length($sseq);
	$st=substr($sseq,0,3);
	$sp=substr($sseq,($slen-3),3);
	print"$snam\t$st\t$sp\n";
        push(@start,$st);
	push(@stop,$sp);
%seen=();
@stuniq = grep{ !$seen{$_} ++} @start;
%seen=();
@spuniq = grep{ !$seen{$_} ++} @stop;
	}
print "stop\t@spuniq\nstart\t@stuniq\n";
