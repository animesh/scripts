my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
my $lenthr=shift @ARGV;chomp $lenthr;
open(F,$main_file_pattern)||die "can't open";
my ($line,$snames,@seqname,@seq,$fresall,$seq,$seqname);

while ($line = <F>) {
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
close F;
my $w;my %m;my $fot;my $t;
my $fresall=$main_file_pattern.".len".$lenthr.".fasta";
open(FRA,">$fresall");
my $fot;
for($fot=0;$fot<=$#seq;$fot++){
my $l=length(@seq[$fot]);
if($lenthr<$l){
@seqname[$fot]=~s/\s+/\_/g;
print FRA"@seqname[$fot]\t$l\n@seq[$fot]\n";
}
}
close FRA;

