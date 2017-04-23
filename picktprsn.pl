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
#open (F3, ">$f3") || die "can't open \"$f3\": $!";
$seq="";
while ($line = <F1>) {
			chomp $line;
	if ($line =~ /^>/){
		push(@seqnameo,$line);	
		if ($seq ne ""){
			push(@seqo,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seqo,$seq);
close F1;

$seq="";
while ($line = <F2>) {
	chomp $line;
	if ($line =~ /^>/){
		chomp $line;
		push(@seqnamen,$line);	
		if ($seq ne ""){
			push(@seqn,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seqn,$seq);
close F2;

$f4=$file1.".rspick";
open (F4, ">$f4") || die "can't open \"$f4\": $!";
$f5=$file1.".rsnpick";
open (F5, ">$f5") || die "can't open \"$f5\": $!";
$f6=$file2.".rspick";
open (F6, ">$f6") || die "can't open \"$f6\": $!";
$f7=$file2.".rsnpick";
open (F7, ">$f7") || die "can't open \"$f7\": $!";
#emb|BX248333.1|MBO248333:c12311-11874
for($c1=0;$c1<=$#seqo;$c1++){
	$seqoo=@seqo[$c1];$seqnameoo=@seqnameo[$c1];@t=split(/:/,$seqnameoo);
	$lo=length($seqoo);$seqoo=substr($seqoo,3,($lo-12));
	if(@t[1]=~/^c/){
		for($c2=0;$c2<=$#seqn;$c2++){
			$seqnn=$seqn[$c2];
			$seqoocon=$seqnn=~s/$seqoo/$seqoo/g;
			if($seqoocon>=1){
				$ct++;$ctn{$c2}=$ct;last;
			}
			elsif($seqoocon==0){
				$cot++;
			}
		}
		if($ct==1){
				print F4"@seqnameo[$c1]\n@seqo[$c1]\n";
				#print F6"@seqnamen[$c2]\n@seqn[$c2]\n";
		}
		elsif($cot>=$c2){
				print F5"@seqnameo[$c1]\n@seqo[$c1]\n";
				#print F7"@seqnamen[$c2]\n@seqn[$c2]\n";
		}
		$ct=0;$cot=0;
		}
	else{
		next;
	}
}

		for($c2=0;$c2<=$#seqn;$c2++){
			if($ctn{$c2}==1){
				print F6"@seqnamen[$c2]\n@seqn[$c2]\n";
			}
			else{
				print F7"@seqnamen[$c2]\n@seqn[$c2]\n";
			}
		}
