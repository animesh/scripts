use strict;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = shift @ARGV;
my $i1 = shift @ARGV; #Accesion column -1 
my $i0 = shift @ARGV; #Description
my $i2 = shift @ARGV; #Sequest Score 

my @files=<$path/*$pat>;
my %protein;
my %uniprot;
my %nc;

print "ID\tStem\tDescription\t";
foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    my $fn=$f1;
    $fn=~s/$path\///g;
    $fn=~s/\.csv$|\.txt$//g;
    print "$fn-$i2\t";
    open (F1, $f1) || die "can't open \"$f1\": $!";
    while (my $line = <F1>) {
		chomp $line;
        $lcnt++;
        if($pat=~/csv/){@tmp=parse_line(',',0,$line);}
        if($pat=~/txt/){@tmp=parse_line('\t',0,$line);}
        if ($lcnt>1){
            @name=split(/\;/,$tmp[$i1]);
            foreach (@name) {
				$_=~s/\'/prime/g;
				$_=~s/\,/comma/g;
				$_=~s/\(|\)/ /g;
				#$_=~s/\[.*\]//g;
				$_=~s/^\s+|\s+$//g;
				$_=~s/\s+/_/g;
                my $key="$_;$f1";
				$protein{$key}.="$tmp[$i2];";
                $nc{"$_"}.="$tmp[$i0];";
				
            }
        } 
    }
    close F1;
}
print "ExperimentsDetected\n";

foreach my $g  (keys %nc){
    my $ocg;
	my @gname= split(/\s+|\-|\_/,$g);
    print "$g\t$gname[0]-$gname[-1]\t$nc{$g}\t";
    foreach  my $f (@files){
        my $key="$g;$f";
        if($protein{$key} ne ""){
			my @vtmp=split(/;/,$protein{$key});
			my $maxv=0;
			foreach (@vtmp){
                if(abs($_)>abs($maxv)){
					$maxv=$_+0;
				}
                #else{$protein{$key}.=";NaN";}
			}
        	print "$maxv\t";
			#print "$protein{$key}\t";
        	$ocg++;
        }
        else{print "\t";}
    }
    print "$ocg\n";
}

__END__	

 perl combinereports.pl . _ProteinGroups.txt 10 1 5 > testPG13.txt


