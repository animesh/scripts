my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
open(F,$main_file_pattern)||die "can't open";
my ($line,$snames,@seqname,@seq,$fresall,$seq,$seqname);
$sl=500;
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
my $w;my %m;my $fot;my $t;my $selscf;
my $fresall=$main_file_pattern.".$sl.fasta";
open(FRA,">$fresall");
my $fot;
for($fot=0;$fot<=$#seq;$fot++){
my $l=length(@seq[$fot]);
@seqname[$fot]=~s/\s+/\_/g;
if($l>$sl){
$selscf++;
print FRA"@seqname[$fot]\n@seq[$fot]\n";
}
}
print "Total Seq - $fot \t Selected Seq - $selscf";
close FRA;

