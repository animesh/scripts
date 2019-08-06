use strict;
use warnings;
use Text::ParseWords;

my $f = shift @ARGV;
unless(-e $f){die "USAGE:perl findProtein.pl proteinGroups.txt";}

my $id = "Protein"; #column name of IDs starts with
my $pattern = qr/\./; #none of the IDs in above column should contain this
my $idi;
my $lcnt = 0;


print "Uniprot ID(s)";
open (F1, $f) || die "can't open \"$f\": $!";
while (my $line = <F1>) {
  chomp $line;
  $line =~ s/\r|\`|\"|\'/ /g;
  $lcnt++;
  my @name=parse_line('\t',0,$line);
  if ($lcnt==1){
    for(my $i=0;$i<=$#name;$i++){if($name[$i]=~/^$id/){ $idi=$i; } }
    print " Idx=$idi\n";#\t$line\n";
  }
  my @names=split(/;/,$name[$idi]);
  my $cntdot=0;
  for(my $i=0;$i<=$#names;$i++){if($names[$i]=~/$pattern/){ $cntdot++;} }
  if($cntdot>$#names){print "$name[$idi]\n";}#"\t$line\n";
}
close F1;


__END__

perl findProtein.pl proteinGroups.txt > proteinGroups.id0.txt
