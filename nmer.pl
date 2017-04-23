$file=shift @ARGV;
open(F,$file);
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
                #$snames=@seqn[0];
                $snames=$line;
                chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,uc($seq));
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,uc($seq));
close F;
for($colo=1;$colo<12;$colo++){
createhash($colo);
}
sub createhash{
	$colo=shift;
        for($x11=0;$x11<=$#seq;$x11++){
                $seq=uc(@seq[$x11]);chomp $seq;
                $len=length($seq);
		$lentot+=$len;
                for($co2=0;$co2<=($len-$colo);$co2++)
                        {$subs=substr($seq,$co2,$colo);
			$nmv++;
                        $mash{$subs}+=1;
                        }
        }
}
#$lentot/=($colo-1);
print "nmer\tvalue\n";
foreach $k (sort {$mash{$b}<=>$mash{$a}} keys %mash) {$nm++;print "$k\t$mash{$k}\n";}
print "$nm\t$nmv*$x11*$lentot\n";

