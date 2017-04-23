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
@base=qw/a t c g/;
open(F,"237UAS1000.txt")||die "can't open";
$seq = "";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
             push(@seqname,@seqn[0]);
             $cc++;
            if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);
foreach $b1 (@base){foreach $b2 (@base){foreach $b3 (@base){foreach $b4 (@base){foreach $b5(@base){foreach $b6 (@base){$comb=$b1.$b2.$b3.$b4.$b5.$b6;push(@combos,$comb);}}}}}}
$tots2=@seqname;
#$tots3=1;
$plan[0][0]=0;
for($x11=0;$x11<$tots2;$x11++){#for($d1=0;$d1<$tots3;$d1++){
$sname=@seqname[$x11];
$sname =~ s/\>//g;
$d9=$x11+1;$plan[0][$d9]=$sname;
#print "$plan[$d9][0]\t";
$testseq=lc(@seq[$x11]);
@elem=split(//,$testseq);
$t1=@elem;
	for($x5=0,$x6=1,$x7=2,$x8=3,$x9=4,$x10=5;$x10<$t1;$x5=$x5+1,$x6=$x6+1,$x7=$x7+1,$x8=$x8+1,$x9=$x9+1,$x10=$x10+1)
	{#print $x21;
	$x21=@elem[$x5].@elem[$x6].@elem[$x7].@elem[$x8].@elem[$x9].@elem[$x10];
	push(@seqcod,$x21);#print "$x21\n";
	}
$cont1=0;
foreach $x12 (@combos){
        foreach $x13 (@seqcod){
                     if($x12 eq $x13)
						 {#print "$x12\n";
						push(@fran,$x12);
						$cont1++;$treehash{$x12}=$cont1;
						}
        			if($x12 eq $x13)
						{
						
						while($testseq =~ /$x12/g)
						{
						$posi=pos($testseq);
						push(@temp,$posi);
						}
						#print "@temp\t";
						#$posit{$x12}=[@temp];
						$posit{$x12}=$posi;
						undef@temp;}
			}
			$cont1=0;
	}
$cont1=0;
#print "$sname\t$testseq\n";
$cont3=0;
#while( ($k,$v) = each %treehash )
#	{#print "$k => $v\n";
	#$plan[($x11+1)][($d1+1)]=$v;
#	}
#while( ($kk,$vv) = each %posit )
#	{#$dr=@$vv;
	#print "$kk => $dr";print "\n";
	#print "$kk => $vv";print "\n";
#	}
@seqcod=0;
#print "\n";
%seen=();
@uniq = grep{ !$seen{$_} ++} @fran;
$tots3=@uniq;
for($d6=1;$d6<=$tots3;$d6++)
	{
	$d7=$d6-1;$plan[$d6][0]=@uniq[$d7];
	}

for($d4=1;$d4<=$tots3;$d4++)
		{foreach $d5 (keys %treehash) {$d7=$x11+1;
	if($plan[$d4][0] eq $d5){$plan[$d4][$d7]=$treehash{$d5};}
		}}
foreach $x16 (keys %treehash){delete $treehash{$x16};}
foreach $x30 (keys %posit){delete $posit{$x30};}
}
#}
$tots3=@uniq;
$tots2=@seqname;
#foreach $fr (@uniq) {print "$fr\n";}
for($d3=0;$d3<=$tots3;$d3++){print "\n";
	for($d2=0;$d2<=$tots2;$d2++){
	print "$plan[$d3][$d2]\t";
}}