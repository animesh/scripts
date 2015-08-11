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
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName MultSeqFile\t\n\n\n";}
$file = shift @ARGV;
open (F, $file) || die "can't open \"$file\": $!";
$seq="";
while ($line = <F>) {chomp $line;
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		#print "Reading\t\tseq no.$c\t$line\n";
		$line=~s/\|/\-/g; $line=~s/\s+//g;#$line=substr($line,1,30);
		push(@seqname,$line);	
		#@seqn=split(/\s+/,$line);push(@seqname,$seqn[0]);#$snames=$line;
		if ($seq ne ""){
			push(@seq,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq,$seq);
close F;
for($c1=0;$c1<=$#seq;$c1++)
{
	$fooo=$c1+1;	
	$sname=@seqname[$c1];
	$seq=uc(@seq[$c1]);
	$N=length($seq);
	$m{$N}++;
	if($N<93){$c10++;}
	
}
$c=0;
foreach $w (sort {$a <=> $b} keys %m){$c+=$m{$w};print "$w\t$m{$w}\t$c\n";}
#$ts=$fooo-$c10;
#print "\n$fooo\n$c10\n$ts\n";