$file=shift @ARGV;chomp $file;
open (F,$file)||die "cant open  :$!";
$seq="";
while ($line = <F>){
        chomp ($line);
        if ($line =~ /^>/){
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne ""){
              push(@seq,uc($seq));
              $seq = "";
            }
        }
        else{
            $seq=$seq.$line;
        }
}
push(@seq,uc($seq));
close F;

$sn1=shift @ARGV;chomp $sn1;
$dn1=shift @ARGV;chomp $sn1;
$sn2=shift @ARGV;chomp $sn2;
$dn2=shift @ARGV;chomp $sn2;
$time=time;

$fas_file=$file.".$time.$sn1$dn1$sn2$dn2.pairedread.fasta";
open(FT,">$fas_file");
$pair1=4000;
$pair2=8000;
$lenp=200;
for($c=0;$c<=$#seq;$c++){
	$name=$seqname[$c];
	$name=~s/contig//g;
	$name+=0;
	$seqlen=length($seq[$c]);
        $mf=$file;
        $mf=~s/\.//g;

	if($name==$sn1 && $dn1==3){
	        
		print FT">SeqF1$sn1$dn1$sn2$dn2 template=Chr1$sn1$dn1$sn2$dn2 dir=F library=Chr_$sn1.$dn1.$sn2.$dn2\n";
        	print FT substr($seq[$c],$seqlen-$pair1/2,$lenp),"\n";

		print FT">SeqF2$sn1$dn1$sn2$dn2 template=Chr2$sn1$dn1$sn2$dn2 dir=F library=Chr_$sn1.$dn1.$sn2.$dn2\n";
        	print FT substr($seq[$c],$seqlen-$pair1/2+$lenp,$lenp),"\n";

	}

	if($name==$sn1 && $dn1==5){
       
                $str=reverse($seq[$c]);
                $str=~tr/ATGCN/TACGN/;
		$lenstr=length($str);
	         
		print FT">SeqF1$sn1$dn1$sn2$dn2 template=Chr1$sn1$dn1$sn2$dn2 dir=F library=Chr_$sn1.$dn1.$sn2.$dn2\n";
                $revstr=substr($str,$lenstr-$pair1/2,$lenp);
                print FT $revstr,"\n";
                
		print FT">SeqF2$sn1$dn1$sn2$dn2 template=Chr2$sn1$dn1$sn2$dn2 dir=F library=Chr_$sn1.$dn1.$sn2.$dn2\n";
                $revstr=substr($str,$lenstr-$pair1/2+$lenp,$lenp);
                print FT $revstr,"\n";

	}


	if($name==$sn2 && $dn2==3){
	
                print FT">SeqR1$sn1$dn1$sn2$dn2 template=Chr1$sn1$dn1$sn2$dn2 dir=R library=Chr_$sn1.$dn1.$sn2.$dn2\n";
                print FT substr($seq[$c],$seqlen-$pair1/2,$lenp),"\n";

                print FT">SeqR2$sn1$dn1$sn2$dn2 template=Chr2$sn1$dn1$sn2$dn2 dir=R library=Chr_$sn1.$dn1.$sn2.$dn2\n";
                print FT substr($seq[$c],$seqlen-$pair1/2+$lenp,$lenp),"\n";


	}

	if($name==$sn2 && $dn2==5){
	        
		print FT">SeqR1$sn1$dn1$sn2$dn2 template=Chr1$sn1$dn1$sn2$dn2 dir=R library=Chr_$sn1.$dn1.$sn2.$dn2\n";
                $revstr=substr($seq[$c],$pair1/2,$lenp);
                $revstr=reverse($revstr);
                $revstr=~tr/ATGCN/TACGN/;
                print FT $revstr,"\n";

	        print FT">SeqR2$sn1$dn1$sn2$dn2 template=Chr2$sn1$dn1$sn2$dn2 dir=R library=Chr_$sn1.$dn1.$sn2.$dn2\n";
                $revstr=substr($seq[$c],$pair1/2+$lenp,$lenp);
                $revstr=reverse($revstr);
                $revstr=~tr/ATGCN/TACGN/;
                print FT $revstr,"\n";

	}

	#$seq{}
}

