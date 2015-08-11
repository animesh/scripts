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

#!usr/bin/perl
$f1 = shift @ARGV;$f2=$f1.".seqpic.txt";
open(F,$f1)||die "can't open $f1";
open(E,">$f2")||die "can't open $f2";

open(F2,"ecol_K12_MG1655genome.gbk")||die "can't open F";
$je=301;$js=110;$sigma="Sigma70";
while ($l=<F2>){	
	if($l=~/^ORIGIN/){
		while($ll=<F2>)
                {
                $ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$ll=~s/\/\///g;$line.=$ll;
                }
        }
}
close F2;
$line=uc($line);
$rline=reverse ($line);
$rline =~ tr/ATCG/TAGC/d;$lgo=length($rline);
#print ">forward\t$f\n$line\n";print ">reverse\t$f\n$rline\n";
while($lin=<F>){
 chomp $lin;
 if($lin=~/^ECK/){
 @t1=split(/\t/,$lin);
 #foreach  (@t1) {print "$c\t $_ \n";$c++;}#print "@t1[5]\n";
 $pos=@t1[2];$str=uc(@t1[5]);$str=~s/\s+//g;
	 if(($pos eq "reverse") and (@t1[4] eq $sigma)){ 
		 $ccc++;
 		 $ci= $line =~ s/$str/$str/g; #print E">$ci\t@t1[0]\t$ccc\t@t1[1]\t@t1[2]\t@t1[3]\t@t1[4]\t$str\n$line\n";
  		 if($ci==0 or $ci>1){print ">$ccc\t$ci\t@t1[0]\t$ccc\t@t1[1]\t@t1[2]\t@t1[3]\t@t1[4]\t$str\n";}
		 while ($rline =~ /$str/g) {
			$posi= (pos $line) - length($&) +1;#print "$posi\n";
			if($posi<110){$moti = (substr($rline,($lgo-($js-$pos)),($je-($js-$pos)))).(substr($rline,0,($posi-$js)));$len=length($moti);}
			else{
				$moti = substr($rline,($posi-$js),$je);$len=length($moti);
			}
			(pos $line)=(pos $rline)-length($&) +1;
			$postss=$lgo-$posi-60+1;$sp=$postss-$js+60-1+1+$len-1-81;$st=$sp-$je+1;
			print E">@t1[0]\t$ccc\t@t1[1]\t@t1[2]\t@t1[3]\t@t1[4]\tPos in GenSeq-$postss\tLen-$len [$sp-$st]\n$moti\n";
		}

	 }
	 elsif(($pos eq "forward") and (@t1[4] eq $sigma)) {
		$ccc++;
		$ci= $line =~ s/$str/$str/g; #print E">$ci\t@t1[0]\t$ccc\t@t1[1]\t@t1[2]\t@t1[3]\t@t1[4]\t$str\n$line\n";
		if($ci==0 or $ci>1){print ">$ccc\t$ci\t@t1[0]\t$ccc\t@t1[1]\t@t1[2]\t@t1[3]\t@t1[4]\t$str\n";}
		while ($line =~ /$str/g) {
			$posi= (pos $line) - length($&) +1; #print "$posi\n";
			if($posi<110){$moti = (substr($line,($lgo-($js-$pos)),($je-($js-$pos)))).(substr($line,0,($posi-$js)));$len=length($moti);}
			else{
				$moti = substr($line,($posi-$js),$je);$len=length($moti);
			}
			(pos $line)=(pos $line)-length($&) +1;
			$postss=$posi+60;$st=$postss-$js-60+1;$sp=$st+$len-1;
			print E">@t1[0]\t$ccc\t@t1[1]\t@t1[2]\t@t1[3]\t@t1[4]\tPos in GenSeq-$postss\tLen-$len [$st-$sp]\n$moti\n";
		}
	 }
	 #else{print "$ccc\t$lin\n";}
 }
}

close F;close E;



