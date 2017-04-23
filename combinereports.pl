use strict;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = shift @ARGV;
my $i1 = shift @ARGV; #ID 
my $i0 = shift @ARGV; #Description
my $i2 = shift @ARGV; #Value 
my $cstr = shift @ARGV; #num or str 

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
				$line=~s/\'/prime/g;
				$line=~s/\,/comma/g;
				$line=~s/\(|\)/ /g;
				$line=~s/^\s+|\s+$//g;
				#$line=~s/\s+/_/g;
        $lcnt++;
        if($pat=~/csv/){@tmp=parse_line(',',0,$line);}
        if($pat=~/txt/){@tmp=parse_line('\t',0,$line);}
        if ($lcnt>1){
            @name=split(/\;/,$tmp[$i1]);
            foreach (@name) {
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
	my @ncgt=split(/;/,$nc{$g});
	my @uniq = do { my %seen; grep { !$seen{$_}++ } @ncgt };
    print "$g\t$gname[0]\t@uniq\t";
    foreach  my $f (@files){
        my $key="$g;$f";
        if($cstr eq "str" and $protein{$key} ne ""){print "$protein{$key}\t";$ocg++;}
        elsif($cstr eq "num" and $protein{$key} ne ""){
			my @vtmp=split(/;/,$protein{$key});
			my $maxv=0;
			foreach (@vtmp){
                if(abs($_)>abs($maxv)){
					$maxv=$_+0;
				}
                else{$protein{$key}.=";NaN";}
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

$ ln -s /cygdrive/y/felles/PROTEOMICS\ and\ XRAY/Articles\ in\ prep/AID/WCXlfq ../
$ perl combinereports.pl ../WCXlfq _Proteins.txt 7 8 30 > /cygdrive/y/felles/PROTEOMICS\ and\ XRAY/Articles\ in\ prep/AID/WCXlfq/WCX_Proteins.txt               

 


