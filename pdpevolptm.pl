use strict;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = shift @ARGV;
my $i1 = shift @ARGV;
my $i2 = shift @ARGV;
my $i5 = shift @ARGV;
my $i7 = shift @ARGV;
my $i11 = shift @ARGV;
my $i14 = shift @ARGV;
my $iexp = shift @ARGV;



my @files=<$path/*$pat>;
my %mrna;
my %nc;
my %sa;

print "FileColumn$i2\t";
foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    my $fn=$f1;
    $fn=~s/$path|$pat|\///g;
    print "$fn-";
    open (F1, $f1) || die "can't open \"$f1\": $!";
    while (my $line = <F1>) {
        $lcnt++;
        if($pat=~/csv/){@tmp=parse_line(',',0,$line);}
        if($pat=~/txt/){@tmp=parse_line('\t',0,$line);}
        if ($lcnt>1){
            @name=split(/\;/,$tmp[$i1]);
            foreach (@name) {
                my $key="$_;$f1";
                my $area=$tmp[$i2]+0;
                if($tmp[$i2]=~/[0-9]/){my $htl="$area [$tmp[$i5]-$tmp[$i7] $tmp[$i11]-$tmp[$i14]]";$mrna{$key}.="$htl ";}
                elsif($tmp[$i2] eq ""){$mrna{$key}.="NA ";}
                else{$mrna{$key}.="$tmp[$i2] ";}                
                $nc{"$_"}++;
            }
            $sa{$f1}+=$tmp[$i2];	   
        }
    }
    close F1;
    print "$sa{$f1}\t";
}
print "ExperimentsDetected\n";

foreach my $g  (keys %nc){
  if($nc{$g}>=$iexp){
    my $ocg;
    print "$g\t";
    foreach  my $f (@files){
        my $key="$g;$f";
        print "$mrna{$key}\t";
        if($mrna{$key}){$ocg++;}
    }
    print "$ocg\n";
  }
}

__END__	

perl  pdpevolptm.pl  /cygdrive/X/Elite/LARS/2013/februar/ 130225_bsa?pep.csv 0 8 5 7 11 14 6 > /cygdrive/X/Elite/LARS/2013/februar/peppho.txt