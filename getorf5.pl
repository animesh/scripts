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
		$line=~s/\|/\-/g; #$line=~s/\s+//g;#$line=substr($line,1,30);
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
for($c1=0;$c1<=$#seq;$c1++){
	$sname=@seqname[$c1];
	@t=split(/\s+/,$sname);
	$s1=@t[1];$s1=~s/\[//g;$s2=@t[3];$s2=~s/\]//g;$s1+=0;$s2+=0;$l1=$c1;$l2=$c1;
	#print "$s1\t$s2\n";
	#print "@t[4]\n";
	if(@t[4]=~/\(REVERSE/){next;
	#print "@t[1]\t@t[3]\n"; 
	#print "$s1\t$s2\n";
	#$m{@t[1]}++;
	#if($N<93){$c10++;}
	}
	else{
	$min=$s1;$max=$s2;
		for($c2=($c1+1);$c2<=$#seq;$c2++){
			$sname2=@seqname[$c2];@t2=split(/\s+/,$sname2);	
			$s11=@t2[1];$s11=~s/\[//g;$s22=@t2[3];$s22=~s/\]//g;$s11+=0;$s22+=0;
			if((@t2[4] eq "Gen") and ($min>$s11)){
				$min=$s11;$l1=$c2;
			}
		}
		for($c3=($c1+1);$c3<=$l3;$c3++){
			$sname3=@seqname[$c3];@t3=split(/\s+/,$sname3);
			$s13=@t3[1];$s13=~s/\[//g;$s23=@t3[3];$s23=~s/\]//g;$s13+=0;$s23+=0;			
			if((@t3[4] eq "Gen") and ($max<$s23)){
				$max=$s23;$l2=$c3;
			}
		}
		for($c5=($l2+1);$c5<=$#seq;$c5++){
			$sname5=@seqname[$c5];@t5=split(/\s+/,$sname5);
			$s15=@t5[1];$s15=~s/\[//g;$s25=@t5[3];$s23=~s/\]//g;$s15+=0;$s25+=0;			
			if((@t5[4] eq "Gen") and ($max>=$s15) and ($min<=$s15)){
				$max=$s25;$l5=$c5;
			}
		}
		$max=$max+3;$length=$max-$min+1;
		print ">$file\tCDS\t$min-$max\t$length\n";
		$c1=$l5+1;$min=0;$max=0;

	}
	
}
#$c=0;
#foreach $w (sort {$b <=> $a} keys %m){$c+=$m{$w};print "$w\t$m{$w}\t$c\n";}
#$ts=$fooo-$c10;
#print "\n$fooo\n$c10\n$ts\n";