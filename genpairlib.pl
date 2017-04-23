$file=shift @ARGV;chomp $file;
open (F,$file)||die "cant open  :$!";
$seq="";
while ($line = <F>){
        chomp ($line);
        if ($line =~ /^>/){
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
        }
        else{
            $seq=$seq.$line;
        }
}
push(@seq,$seq);
close F;

$time=time;
$libname=shift @ARGV;
$dist=shift @ARGV;

$fas_file=$file.".$time.$libname.$dist.pairedread.fasta";
open(FT,">$fas_file");
$lenp=100;
for($c=0;$c<=$#seq;$c++){
	$name=$seqname[$c];
	$name=~s/contig//g;
	$name+=0;
	$seqlen=length($seq[$c]);
        $mf=$file;
        $mf=~s/\.//g;

		
		$count=0;
		while($count<2 && $seqlen>($dist+2*$lenp)){
			$count++;
			$tempname=$libname.$dist.$lenp.$c.$count;
			$seqnameF=$tempname."F";
			$seqnameR=$tempname."R";
		        print FT">$seqnameF template=$tempname dir=F library=$libname\n";
        	        print FT substr($seq[$c],$count*$lenp,$lenp),"\n";
		        print FT">$seqnameR template=$tempname dir=R library=$libname\n";
        	        $revstr=substr($seq[$c],$count*$lenp+$dist,$lenp);
                	$revstr=reverse($revstr);
	                $revstr=~tr/ATGCN/TACGN/;
        	        print FT $revstr,"\n";
		}
}


