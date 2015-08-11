if((@ARGV)!=2){die "2 args needed\n";}

$file1=shift @ARGV;
$file2=shift @ARGV;
open(F1,$file1);
open(F2,$file2);
$length1=5;
$length2=$length1;

while ($line = <F2>) {
        chomp ($line);
        if ($line =~ /^>/){
                $snames=$line;
                chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}push(@seq,$seq);
$seq="";
close F2;



while(<F1>){
	@t1=split(/\s+/);
	if(@t1[0] eq "C"){
		$v1="C.".@t1[1];
		$v2="C.".@t1[3];
		$e1=@t1[2];
		$e2=@t1[4];
		$readcnt=@t1[5];
                $node{$v1}++;
		$node{$v2}++;
		$label="$e1->$e2($readcnt)";
		if($e1==3 && $e2==5){
			print ">FF.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
			$fas1=substr(@seq[@t1[1]-1],-($length1),$length1);
			$fas2=substr(@seq[@t1[3]-1],0,$length2);
			$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
			$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
			$rfastest1=reverse($fastest1);
			$rfastest2=reverse($fastest2);
			$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
			$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
			$rrfastest1=reverse($rfastest1);
			$rrfastest2=reverse($rfastest2);
			print "5\t".$fastest1."\t3"."\n"."3\t".$rrfastest1."\t5"."\n"."5\t".$fastest2."\t3"."\n"."3\t".$rrfastest2."\t5"."\n".$fas1."\n".$fas2."\n";
			print $fas1.$fas2."\n";

			
		}
		if($e1==5 && $e2==3){
			print ">RR.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
			$fas1=substr(@seq[@t1[1]-1],0,$length1);
			$rfas1=reverse($fas1);
			$rfas1 =~ tr/ACGTacgt/TGCAtgca/;
			$rrfas1=reverse($rfas1);
			$fas2=substr(@seq[@t1[3]-1],-($length2),$length2);
			$rfas2=reverse($fas2);
			$rfas2 =~ tr/ACGTacgt/TGCAtgca/;
			$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
			$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
			$rfastest1=reverse($fastest1);
			$rfastest2=reverse($fastest2);
			$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
			$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
			$rrfastest1=reverse($rfastest1);
			$rrfastest2=reverse($rfastest2);
			print "5\t".$fastest1."\t3"."\n"."3\t".$rrfastest1."\t5"."\n"."5\t".$fastest2."\t3"."\n"."3\t".$rrfastest2."\t5"."\n".$fas1."->".$rfas1."->".$rrfas1."\n".$fas2."->".$rfas2."\n";
			print $rrfas1.$rfas2."\n";

			
		}
		if($e1==3 && $e2==3){
			print ">FR.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
			$fas1=substr(@seq[@t1[1]-1],-($length1),$length1);
			$fas2=substr(@seq[@t1[3]-1],-($length2),$length2);
			$rfas2=reverse($fas2);
			$rfas2 =~ tr/ACGTacgt/TGCAtgca/;
			$revcomp1 = reverse($fas2);
			$revcomp1 =~ tr/ACGTacgt/TGCAtgca/;
			$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
			$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
			$rfastest1=reverse($fastest1);
			$rfastest2=reverse($fastest2);
			$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
			$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
			$rrfastest1=reverse($rfastest1);
			$rrfastest2=reverse($rfastest2);
			print "5\t".$fastest1."\t3"."\n"."3\t".$rrfastest1."\t5"."\n"."5\t".$fastest2."\t3"."\n"."3\t".$rrfastest2."\t5"."\n".$fas1."\n".$fas2."->".$rfas2."\n";
			print $fas1.$rfas2."\n";

			
		}
		if($e1==5 && $e2==5){
			print ">RF.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
			$fas1=substr(@seq[@t1[1]-1],0,$length1);
			$rfas1=reverse($fas1);
			$rfas1 =~ tr/ACGTacgt/TGCAtgca/;
			$rrfas1=reverse($rfas1);
			$fas2=substr(@seq[@t1[3]-1],0,$length2);
			$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
			$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
			$rfastest1=reverse($fastest1);
			$rfastest2=reverse($fastest2);
			$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
			$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
			$rrfastest1=reverse($rfastest1);
			$rrfastest2=reverse($rfastest2);
			print "5\t".$fastest1."\t3"."\n"."3\t".$rrfastest1."\t5"."\n"."5\t".$fastest2."\t3"."\n"."3\t".$rrfastest2."\t5"."\n".$fas1."->".$rfas1."->".$rrfas1."\n".$fas2."\n";
			print $rrfas1.$fas2."\n";
		}
#		print "@seqname[@t1[1]-1]\n@seq[@t1[1]-1]\n";
#		print "@seqname[@t1[3]-1]\n@seq[@t1[3]-1]\n";
	}
	elsif (@t1[0] =~ /[0-9]/){
		$clen{"C.@t1[0]"}=@t1[2];
		$cdep{"C.@t1[0]"}=@t1[3];
		$cnam{"C.@t1[0]"}=@t1[1];
		push(@cl,@t1[2]);
	}
}
close F1;


