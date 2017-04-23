$f1=shift @ARGV;
undef @seqname;undef @seq;
$seq="";
open(F1,$f1)||die "can't open";
while($line=<F1>){
        #chomp ($line);
	$line=~s/\n/ /g;
        if ($line =~ /^>/){
             @seqn=split(/\s+|\_/,$line);
                $snamessplit=$line;
		$snamessplit=~s/\s+/\_/g;
		$snamessplit=~s/\_$//;
		
                $snames=$line;
                chomp $snames;
             push(@seqname,$snames);
             push(@seqnamesplit,$snamessplit);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      	} 
	else {
		$seq=$seq.$line;
      	}
}
push(@seq,$seq);

close F1;

$f2=shift @ARGV;
open(F2,$f2);
while($l2=<F2>){
	@t=split(/\s+/,$l2);
	$percent=@t[1];
	$name=@t[0];
	@tn=split(/\_/,$name);
	$ln=@tn[3];
	$hname=@t[0];
	@tne=split(/\=/,$ln);
	$l=@tne[1];
	#print "$name\t$percent\t$l\t$ln\n";
	$sighit{$hname}=0;
	if((@t[2] >0 and abs($l-@t[2])/$l <= 10 and $percent>90) or $percent==100){
		#print "IFF $hname\t$name\t$percent\t$l\t$ln\t($l-@t[2])/$l\n";	
		#print "IFF@t[1]\t@t[5]\n";
		$sighit{$hname}=1;
	}
}
close F2;


for($fot=0;$fot<=$#seq;$fot++){
	$sname=@seqname[$fot];
	$seqs=@seq[$fot];
	$snames=@seqnamesplit[$fot];
	#print "$sname\t$snames\t$sighit{$snames}\n";
	if($sighit{$snames} == 1){
		#print "$sname\n$seqs\n";
		#print "$sname\n";
		
	}
	if($sighit{$snames} == 0){
		print "$sname\n$seqs\n";
		#print "$sname\n";
		
	}
	$l=length(@seq[$fot]);
}

