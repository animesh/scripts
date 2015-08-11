$f1=shift @ARGV;
undef @seqname;undef @seq;
$seq="";
open(F1,$f1)||die "can't open";
while($line=<F1>){
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\s+/,$line);
                $snamessplit=@seqn[0];
		$snamessplit=~s/\>//g;
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
	#print "@t[1]\t@t[5]\n";
	if(@t[5] eq "significant"){
		#print "IFF@t[1]\t@t[5]\n";
		$sighit{@t[1]}=1+0;
	}
}
close F2;


for($fot=0;$fot<=$#seq;$fot++){
	$sname=@seqname[$fot];
	$seqs=@seq[$fot];
	$snames=@seqnamesplit[$fot];
#	print "$sname\t$snames";
	if($sighit{$snames} != 1){
		print "$sname\n$seqs\n";
		
	}
	$l=length(@seq[$fot]);
}


