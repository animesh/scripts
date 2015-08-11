$main_file_pattern=shift @ARGV;
chomp $main_file_pattern;
open(F,$main_file_pattern)||die "can't open";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
		$snames=$line;
		chomp $snames;
		$snames=~s/\s+/ /g;
		$snames=~s/^\s+//g;
        	@ty=split(/\s+/,$snames);
        	push(@seqname,@ty[0]);
                if ($seq ne ""){
              	push(@seq,uc($seq));
              	$seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,uc($seq));
$seq="";
close F;
my $fresall=$main_file_pattern.".all.fasta";
open(FRA,">$fresall");
for($fot=0;$fot<=$#seq;$fot++){
@seqname[$fot]=~s/\>|\s+//g;
print "@seqname[$fot]\n";
$Seqname.=@seqname[$fot];
$Seq.=@seq[$fot];
}
print FRA">$Seqname\n$Seq\n";
close FRA;

