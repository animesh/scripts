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
open(FI,"annogenescanpfchr2.csv");
while($kl=<FI>){
@temp=split(/\,/,$kl);
push(@start,@temp[0]);
#push(@stop,@temp[1]);
push(@tots,@temp[2]);
}close FI;
$lens=@start;
#print "enter the start position \n";
#$start=<>;
#chomp($start);
#print "enter the stop position \n";
#$end=<>;
#chomp($end);
#print "enter the quality \n";
#$qual=<>;
#chomp($qual);

open F1,"xen";
open (FILEOUT1, ">>pfchr2.genescanresult");
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
foreach $WE (@seq)
{
@seqnew=split(//,$WE);
unshift(@seqnew,0);
#$len=@start;
for($dd=0;$dd<$lens;$dd++)
{$star=@start[$dd];
$leng=@tots[$dd]+@start[$dd]-1;
print "$star\t$leng\n";
	for($c=$star;$c<($leng);$c++)
	{
	$seq1=$seq1.@seqnew[$c];
	}$c=0;
print FILEOUT1">the subsequence of  pfchr2 from $star to $leng\n$seq1\n";
$seq1="";
}
}
close FILEOUT1;
close F1;
