use strict;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = shift @ARGV;
my $i1 = shift @ARGV;
my $i2 = shift @ARGV;
my $i4 = shift @ARGV;
my $i8 = shift @ARGV;


my @files=<$path/*$pat>;
my %mrna;
my %nc;

print "Description,Gene,";
foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    my $fn=$f1;
    $fn=~s/$path\///g;
    $fn=~s/\.csv$|\.txt$//g;
    print "$fn-$i2;$i4;$i8,";
    open (F1, $f1) || die "can't open \"$f1\": $!";
    while (my $line = <F1>) {
        $lcnt++;
        if($pat=~/csv/){@tmp=parse_line(',',0,$line);}
        if($pat=~/txt/){@tmp=parse_line('\t',0,$line);}
        if ($lcnt>1){
            @name=split(/\;/,$tmp[$i1]);
            foreach (@name) {
				$_=~s/\'/prime/g;
				$_=~s/\,/comma/g;
				$_=~s/\[Master\ Protein\]//g;
				$_=~s/^\s+//g;
                my $key="$_;$f1";
                #my $area=($tmp[$i2]+$tmp[$i4]+$tmp[$i8])/3;
                #if($tmp[$i2]=~/[0-9]/ and $tmp[$i4]=~/[0-9]/ and $tmp[$i8]=~/[0-9]/){my $htl="$area";$mrna{$key}.="$htl ";}
                if($tmp[$i2] or $tmp[$i4] or $tmp[$i8]){$mrna{$key}.="$tmp[$i2];$tmp[$i4];$tmp[$i8];";}
                #elsif($tmp[$i2] eq ""){$mrna{$key}.="NA ";}
                else{$mrna{$key}.="0;0;0;";}                
                $nc{"$_"}++;
            }
        } 
    }
    close F1;
}
print "ExperimentsDetected\n";

foreach my $g  (keys %nc){
    my $ocg;
	my ($gname)= $g =~ m/GN *= *([^,; ]*)/;
    print "$g,$gname,";
    foreach  my $f (@files){
        my $key="$g;$f";
        if($mrna{$key}){
        	print "$mrna{$key},";
        	$ocg++;
        }
        else{print " , ";}
    }
    print "$ocg\n";
}

__END__	

perl combpdrep.pl /cygdrive/f/promec/Qexactive/Berit_Sissel/data/backup/berit/ _ProteinGroups.txt 10 5 7 9 > t6.csv



