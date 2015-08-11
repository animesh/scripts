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
open(F,"tes4.txt");
$out="co.txt";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
		$snames=@seqn[0];
		chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}close F;
open(FFF,"4.txt");
while ($line = <FFF>) {
        chomp ($line);
		push(@combos,$line);
		#print "$line\n";
}close FFF;
push(@seq,$seq);
$tots2=@seqname;
$plan[0][0]=0;$cont=0;	
for($c1=0;$c1<=$#combos;$c1++){$r1=@combos[$c1];for($c2=0;$c2<=$#combos;$c2++){
	$r2=@combos[$c2];	
if($r1 ne $r2){$cont++;	
for($x11=0;$x11<$tots2;$x11++){$sname=@seqname[$x11];
		chomp $sname;
		$sname =~ s/\>//g;
		@tr=split(/ /,$sname);
		$sname=@tr[0];$plan[0][($x11+1)]=$sname;
		print "$sname\t";
		$testseq=lc(@seq[$x11]);
		$cor1=$testseq =~ s/$r1/$r1/g;
		$cor2=$testseq =~ s/$r2/$r2/g;
			if(($cor1 > 0 and $cor2 > 0) and ($cor1 < 4 and $cor2 < 4)){#$cont++;
$plan[$cont][(0)]="$r1 and $r2";
$plan[$cont][($x11+1)]="$cor1 and $cor2";
print "$r1\-$r2\*$cor1\-$cor2\t";	
				}#else{$plan[$cont][($x11+1)]="$cor1 and $cor2";}
			}#else{$cont;}						
	}else{#$plan[$cont][($x11+1)]="none";
		last;}
}
print "\n";
}
open (FO,">$out");
$contis=$cont+1;
for($d3=0;$d3<=($contis);$d3++){for($d2=0;$d2<=$tots2;$d2++){
print FO"$plan[$d3][$d2]\t";
}
print FO"\n";
}
#close FO;
open FN,"co.txt";
$outn="con.txt";
open FNN,"con.txt";
while($lo=<FN>)
{if($lo ne ""){$l=$lo;print FNN"$l";}
else{chomp $lo;$l.=$lo;}
}