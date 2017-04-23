#open(F1,"trimfile.txt");
open(F1,"tf");
$thresh=0;
#open_file("all.fna");
open_file("al");
while(<F1>){
	chomp;
        $c++;
        $name=$_;
        $name=~s/\s+/\_/g;
	@tmp=split(/\s+/,);        
        $namesubstr=substr($name,9,5);
        $dirstr=uc(substr($name,15,1));
        $libstr=substr($name,0,9);
	$n1=@tmp[0];
	@n2=split(/\_/,$n1);
	$n4=@n2[0];
	if(@tmp[2]>$thresh){
		if($dirstr eq "L"){
			$lp{"$n4.$dirstr"}="$name template=$namesubstr dir=F library=$libstr";
		}
		if($dirstr eq "R"){
			$rp{"$n4.$dirstr"}="$name template=$namesubstr dir=R library=$libstr";
		}
		$ri{$n4}++
	}
}
close F1;


$time=time;
foreach (sort {$ri{$b}<=>$ri{$a}} keys %ri){
	$l="$_.L";
	$r="$_.R";
	@t1=split(/\_/,$lp{$l});
	@t2=split(/\_/,$rp{$r});
		if($ri{$_}==2){
			$lenlink=length($seqhash{$_});
			@tmp=split(/\_/,$lp{$l});
                        $ls=@tmp[2];
                        @tmp=split(/\-/,$ls);
                        $ls1=@tmp[0];
			$ls2=@tmp[1];
                        @tmp=split(/\_/,$rp{$r});
                        $rs=@tmp[2];
                        @tmp=split(/\-/,$rs);
                        $rs1=@tmp[0];
                        $rs2=@tmp[1];
			$leftseq=substr($seqhash{$_},$ls1-1,$ls2-$ls1+1);
			$rightseq=substr($seqhash{$_},$rs1-1,$rs2-$rs1+1);
			$linkerseq=substr($seqhash{$_},$ls2,$rs1-$ls2-1);
			$totallengthseq=length($leftseq)+length($rightseq)+length($linkerseq);
			print "$_\t$ri{$_}\t$lp{$l}\t$rp{$r}\t$lenlink\t$totallengthseq\t$ls1\t$ls2\t$rs1\t$rs2\t$seqhash{$_}\t$leftseq\t$rightseq\t$linkerseq\n";
		}
}

sub open_file{
        my $other_file_pattern=shift;
        my $line;
        open(FO,$other_file_pattern)||die "can't open";
        my $seq;
        my $snames;
        while ($line = <FO>) {
                chomp ($line);
        	if ($line =~ /^>/){
                	$snames=$line;
			@tmp=split(/\s+/,$snames);
			$snames=@tmp[0];
			$snames=~s/\>//g;
		}
		if ($line =~ /^Bases/){
			$slseq=$line;
                        @tmp=split(/\s+/,$slseq);
                        $slseq=@tmp[1];
                        $slseq=~s/\s+//g;
			$seqhash{$snames}=$slseq;
		}
	}
}

__END__

