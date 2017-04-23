my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
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
my $fot;
for($fot=0;$fot<=$#seq;$fot++){
#for($fot=0;$fot<1;$fot++){
my $l=length(@seq[$fot]);
if($l>500000){
my $fresall=$main_file_pattern.".tmp.fas";
open(FRA,">$fresall");
@seqname[$fot]=~s/\s+/\_/g;
print FRA">@seqname[$fot]\n@seq[$fot]\n";
for(my $c2=1;$c2<=10;$c2++){
#for(my $c2=1;$c2<=1;$c2++){
my $fc="s_all.n.fasta.$c2.fna";
my $bam="$main_file_pattern.$fot.s_all.$c2.bam";
print "$fot of @seqname[$fot] against $fc written in $bam\n";
system("/home/animesh/export/nv26/bin/runMapping -bam -cpu 12 -force -o celBSRM $fresall $fc");
system("mv celBSRM/454Contigs.bam $bam");
}
}
}

