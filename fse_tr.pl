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

if( @ARGV ne 1){die "\nUSAGE\t\"ProgName MultSeqFile\t\n\n\n";}
$file = shift @ARGV;
use Math::Complex;
$pi=pi;
$i=sqrt(-1);
open (F, $file) || die "can't open \"$file\": $!";
$seq="";while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             #@seqn=split(/\t/,$line);$snames=@seqn[0];$snames=~s/>//;1/1;
				$snames=$line;
                chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);close F;

$s="ACDEFGHIKLMNPQRSTVWY";
@aad=aadist($s);

for($c1=0;$c1<=$#seq;$c1++)
{
$seq=uc(@seq[$c1]);
$sname=@seqname[$c1];
#$foo=$sname."ft"."\.out";
#open FO,">$foo";
$cl=41;
$N=length($seq);
	if($c1<=12 and $c1>=0){
		$N1+=$N;
		#print "$N1\t$N\n";
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aado1{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aado1{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class1($N);undef %aado1;
	}
	undef %aad;
	if($c1<=19 and $c1>=13){
		$N2+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aado2{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aado2{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class2($N);undef %aado2;
	}	
	undef %aad;
	if($c1<=30 and $c1>=19){
		$N3+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aado3{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aado3{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class3($N);undef %aado3;
	}	
	undef %aad;
	if($c1<=37 and $c1>=31){
		$N4+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aado4{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aado4{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class4($N);undef %aado4;
	}	
	undef %aad;
	if($c1<=46 and $c1>=38){
		$N5+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aado5{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aado5{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class5($N);undef %aado5;
	}	
	undef %aad;
	if($c1<=53 and $c1>=47){
		$N6+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aado6{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aado6{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class6($N);undef %aado6;
	}	
	undef %aad;
	if($c1<=83 and $c1>=54){
		$N7+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt1{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt1{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class7($N);undef %aadt1;
	}	
	undef %aad;
	if($c1<=92 and $c1>=84){
		$N8+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt2{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt2{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class8($N);undef %aadt2;
	}	
	undef %aad;
	if($c1<=108 and $c1>=93){
		$N9+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt3{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt3{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class9($N);undef %aadt3;
	}	
	undef %aad;
	if($c1<=115 and $c1>=109){
		$N10+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt4{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt4{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class10($N);undef %aadt4;
	}	
	undef %aad;
	if($c1<=123 and $c1>=116){
		$N11+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt5{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt5{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class11($N);undef %aadt5;
	}	
	undef %aad;
	if($c1<=136 and $c1>=124){
		$N12+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt6{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt6{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class12($N);undef %aadt6;
	}	
	undef %aad;
	if($c1<=144 and $c1>=137){
		$N13+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt7{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt7{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class13($N);undef %aadt7;
	}	
	undef %aad;
	if($c1<=153 and $c1>=145){
		$N14+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt8{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt8{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class14($N);undef %aadt8;
	}	
	undef %aad;
	if($c1<=162 and $c1>=154){
		$N15+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadt9{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadt9{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class15($N);undef %aadt9;
	}	
	undef %aad;
	if($c1<=191 and $c1>=163){
		$N16+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth1{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth1{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class16($N);undef %aadth1;
	}	
	undef %aad;
	if($c1<=202 and $c1>=192){
		$N17+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth2{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth2{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class17($N);undef %aadth2;
	}	
	undef %aad;
	if($c1<=213 and $c1>=203){
		$N18+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth3{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth3{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class18($N);undef %aadth3;
	}	
	undef %aad;
	if($c1<=226 and $c1>=214){
		$N19+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth4{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth4{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class19($N);undef %aadth4;
	}	
	undef %aad;
	if($c1<=236 and $c1>=227){
		$N20+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth5{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth5{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class20($N);undef %aadth5;
	}	
	undef %aad;
	if($c1<=245 and $c1>=237){
		$N21+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth6{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth6{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class21($N);undef %aadth6;
	}	
	undef %aad;
	if($c1<=255 and $c1>=246){
		$N22+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth7{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth7{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class22($N);undef %aadth7;
	}	
	undef %aad;
	if($c1<=266 and $c1>=256){
		$N23+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth8{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth8{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class23($N);undef %aadth8;
	}	
	undef %aad;
	if($c1<=277 and $c1>=267){
		$N24+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadth9{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadth9{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class24($N);undef %aadth9;
	}	
	undef %aad;
	if($c1<=284 and $c1>=278){
		$N25+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadf1{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadf1{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class25($N);undef %aadf1;
	}	
	undef %aad;
	if($c1<=297 and $c1>=285){
		$N26+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadf2{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadf2{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class26($N);undef %aadf2;
	}	
	undef %aad;
	if($c1<=311 and $c1>=298){
		$N27+=$N;
		for($c=0;$c<=$N;$c=($c+(($cl-1)/2))){
		$t=substr($seq,$c,$cl);$l=length($t);
			if($l>=(($cl-1)/2)){
				$s=$t;$l=length($s);
				@t2=split(//,$s);
				for($c2=0;$c2<=$#t2;$c2++){
					for($c3=($c2+1);$c3<=$#t2;$c3++){
						$tag=@t2[$c2].':'.@t2[$c3];
						$aadf3{$tag}.=":".($c3-$c2);
						$rtag=reverse($tag);
						$aadf3{$rtag}.=":".($c3-$c2);
					}
				}
				$s="";
			}
		}
		class27($N);undef %aadf3;
	}	

}


sub aadist{
	$s=shift;$l=length($s);
	@t2=split(//,$s);
	for($c2=0;$c2<=$#t2;$c2++){
		for($c3=($c2);$c3<=$#t2;$c3++){
			$tag=@t2[$c2].':'.@t2[$c3];
			push(@aad,$tag);
		}
	}
	$s="";
	return @aad;
}
sub class1 {
	$N1=shift;
	#%aado1=shift;
	#print "$N1\n\n\n\n";
	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aado1{$q});#print "$N1\t$aado1{$q}\t";
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N1;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class2 {
	$N2=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aado2{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N2;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class3 {
	$N3=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aado3{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N3;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class4 {
	$N4=shift;
	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aado4{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N4;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class5 {
	$N5=shift;
	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aado5{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N5;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class6 {
	$N6=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aado6{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N6;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class7 {
	$N7=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt1{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N7;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}


sub class8 {
	$N8=shift;
	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt2{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N8;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class9 {
	$N9=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt3{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N9;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class10 {
	$N10=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt4{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N10;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class11 {
	$N11=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt5{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N11;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class12 {
	$N12=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt6{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N12;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class13 {
	$N13=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt7{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N13;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class14 {
	$N14=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt8{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N14;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0\n";
}
sub class15 {
	$N15=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadt9{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N15;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class16 {
	$N16=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth1{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N16;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0\n";
}

sub class17 {
	$N17=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth2{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N17;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0\n";
}

sub class18 {
	$N18=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth3{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N18;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0\n";
}


sub class19 {
	$N19=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth4{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N19;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0\n";
}

sub class20 {
	$N20=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth5{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N20;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0\n";
}

sub class21 {
	$N21=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth6{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N21;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0\n";
}


sub class22 {
	$N22=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth7{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N22;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0\n";
}

sub class23 {
	$N23=shift;
	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth8{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N23;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0\n";
}

sub class24 {
	$N24=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadth9{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N24;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0\n";
}

sub class25 {
	$N25=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadf1{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N25;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0\n";
}


sub class26 {
	$N26=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadf2{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N26;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0\n";
}

sub class27 {
	$N27=shift;

	for($c=0;$c<=$#aad;$c++){
		$q=@aad[$c];
		$t=$q;
		$t=~s/\:/ /g;
		#$aado1{$q}=~s/\:/  /g;
		@fre=split(/\:/,$aadf3{$q});
		for($c11=0;$c11<=$#fre;$c11++){
			$freqc{@fre[$c11]}++;
		}
		#print "$t\t$aado1{$q}\t";
		for($c12=1;$c12<$cl;$c12++){
		#	print "$c12-$freqc{$c12}  ";
			$norm1=$freqc{$c12}/$N27;
			print "$norm1  ";
		}
		#print "\n";
		undef %freqc;
	}
	print "0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1\n";

}



