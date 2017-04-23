my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
open(F,$main_file_pattern)||die "can't open";
my ($line,$snames,@seqname,@seq,$fresall,$seq,$seqname);
$gl=600000000;
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
my $fresall=$main_file_pattern.".length";
open(FRA,">$fresall");
my $fot;
for($fot=0;$fot<=$#seq;$fot++){
my $l=length(@seq[$fot]);
@seqname[$fot]=~s/\s+/\_/g;
$lenhash{@seqname[$fot]}=$l;
}
$cnt=0;
foreach $sn (sort {$lenhash{$b} <=> $lenhash{$a}} keys %lenhash){
$tl+=$lenhash{$sn};
print FRA"$sn\t$lenhash{$sn}\t$tl\t",int($gl/2),"\t";
if($tl>=($gl/2) && $cnt<1){
        $cnt++;
        $n50=$lenhash{$sn};
#        print FRA"N50-$n50\t";
        }
print FRA"\n";
}
print "N50 - $n50";
close FRA;

