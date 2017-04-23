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
if( @ARGV ne 2){die "\nUSAGE\t\"ProgName Actual FFN Predicted FFN\n\n\n";}
$file1 = shift @ARGV;$file2 = shift @ARGV;
$f3=$file1."_".$file2.".pickfs.ffn";
open (F1, $file1) || die "can't open \"$file1\": $!";
open (F2, $file2) || die "can't open \"$file2\": $!";
open (F3, ">$f3") || die "can't open \"$f3\": $!";

while ($line = <F1>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		@seqn=split(/\:/,$line);
		@seqn=split(/\-/,@seqn[1]);
		#print "@seqn[0]\t@seqn[1]\n";
		if(@seqn[0]!~/^c/){
			push(@seqf,$seqn[0]);
			push(@seql,$seqn[1]);
			push(@seqname1,$line);
			#$cnt++;
			#print "@seqn[0]\t@seqn[1]\n";
		}
	}
}
close F1;
#print "$cnt\n";
while ($line = <F2>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		@seqn=split(/\t/,$line);
		@seqn=split(/\s+/,@seqn[2]);
		#print "@seqn[0]\t@seqn[1]\n";
			push(@seqff,$seqn[0]);
			push(@seqll,$seqn[3]);
			push(@seqname2,$line);
			#print "@seqn[0]\t@seqn[3]\n";
	}
}
close F2;
#%seen=();
#@seqff = (grep{ !$seen{$_} ++} @seqff);#undef @all;
#@seqff = (sort {$a <=> $b} @seqff);
#%seen=();
#@seqll = (grep{ !$seen{$_} ++} @seqll);
#@seqll = (sort {$a <=> $b} @seqll);
#%seen=();
#@seqf = (grep{ !$seen{$_} ++} @seqf);#undef @all;
#@seqf = (sort {$a <=> $b} @seqf);
#%seen=();
#@seql = (grep{ !$seen{$_} ++} @seql);
#@seql = (sort {$a <=> $b} @seql);

for($c2=0;$c2<=$#seqff;$c2++){
	$st2=@seqff[$c2];
	$sp2=@seqll[$c2];
	for($c1=0;$c1<=$#seqf;$c1++){
		$st1=@seqf[$c1];
		$sp1=@seql[$c1];
			if(($st1 >= $st2) and ($sp1 <= $sp2)){
			#print "@seqname2[$c1]\n";
			#print F3"@seqname1[$c1]\n";
			$cnt++;
			push(@pre,$c2);
			push(@act,$c1);
			next;
			}
		}
}

#print "Total Forward Seq Predicted - $c2\n";
#print "Total Forward Pred Seq Covered- $cnt ($c1)\n";
#
%seen=();
@act = (grep{ !$seen{$_} ++} @act);#undef @all;
@act = (sort {$a <=> $b} @act);
%seen=();
@pre = (grep{ !$seen{$_} ++} @pre);
@pre = (sort {$a <=> $b} @pre);



open (F1, $file1) || die "can't open \"$file1\": $!";
open (F2, $file2) || die "can't open \"$file2\": $!";

$seq="";
while ($line = <F1>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		#print "Reading\t\tseq no.$c\t$line\n";
		#$line=~s/\|/\-/g; $line=~s/\s+//g;#$line=substr($line,1,30);
		push(@seqname11,$line);	
		#@seqn=split(/\s+/,$line);push(@seqname,$seqn[0]);#$snames=$line;
		if ($seq ne ""){
			push(@seq11,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq11,$seq);
close F1;

$seq="";
while ($line = <F2>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		#print "Reading\t\tseq no.$c\t$line\n";
		#$line=~s/\|/\-/g; $line=~s/\s+//g;#$line=substr($line,1,30);
		push(@seqname22,$line);	
		#@seqn=split(/\s+/,$line);push(@seqname,$seqn[0]);#$snames=$line;
		if ($seq ne ""){
			push(@seq22,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq22,$seq);
close F2;

close F3;
$f4=$file1.".fspick";
open (F4, ">$f4") || die "can't open \"$f4\": $!";
$f5=$file1.".fsnpick";
open (F5, ">$f5") || die "can't open \"$f5\": $!";
$f6=$file2.".fspick";
open (F6, ">$f6") || die "can't open \"$f6\": $!";
$f7=$file2.".fsnpick";
open (F7, ">$f7") || die "can't open \"$f7\": $!";

for($c=0;$c<=$#seq11;$c++){
	$seq{@seqname11[$c]}=@seq11[$c];
}
for($c=0;$c<=$#seq22;$c++){
	$seq{@seqname22[$c]}=@seq22[$c];
}

for($c=0;$c<=$#seqname1;$c++){
	for($c1=0;$c1<=$#act;$c1++){
		if($c==@act[$c1]){
			#print "@seqname1[@act[$c1]]-$seqname\n";
			print F4"@seqname1[$c]\n$seq{@seqname1[@act[$c1]]}";
			#next;
		}
		else{
			#print F5"@seqname1[$c]]\n@seq11[$c]";
			#next;
			$c2++;
			
		}
	}
	$m{$c}=$c2;$c2=0;
}
for($c=0;$c<=$#seqname1;$c++){
		if($m{$c}==$c1){
			print F5"@seqname1[$c]\n$seq{@seqname1[$c]}";
		}
}
$c=$c-1;
#print "$m{$c}\t$c1\t$c2\n";
undef %m;

for($c=0;$c<=$#seq22;$c++){$c2=0;
	for($c1=0;$c1<=$#pre;$c1++){
		if($c==@pre[$c1]){
			#print "@seqname1[@act[$c1]]-$seqname\n";
			print F6"@seqname2[$c]\n$seq{@seqname2[@pre[$c1]]}";
			#next;
		}
		else{
			#print F5"@seqname1[$c]]\n@seq11[$c]";
			#next;
			$c2++;
			$m{$c}=$c2;
		}
	}$m{$c}=$c2;
}

for($c=0;$c<=$#seq22;$c++){
		if($m{$c}==$c1){
			print F7"@seqname2[$c]\n$seq{@seqname2[$c]}";
		}
}
undef %m;
undef %seq;