use strict;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = shift @ARGV;
my $i3 = shift @ARGV; #ID
my $i4 = shift @ARGV; #Description
my $i5 = shift @ARGV; #Value
my $cstr = shift @ARGV; #num or str

if($cstr){print "$path;$pat;$i3;$i4;$i5;$cstr\tDescription\t";}
else{die("use: perl combineReports.pl folder-name file-name-ending-pattern (file should have header which start with following column names) ID-column description-column Value-column string/number(combine string while absolute maximum)")}

my @files=<$path/*$pat>;
my %protein;
my %uniprot;
my %nc;

foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    my $fn=$f1;
    my $i1;
    my $i0;
    my $i2;
    $fn=~s/$pat//g;
    $fn=~s/$path//g;
    open (F1, $f1) || die "can't open \"$f1\": $!";
    while (my $line = <F1>) {
		    chomp $line;
				$line=~s/\'/prime/g;
        $line=~s/\,/comma/g;
#        $line=~s/\"/quote/g;
        $line=~s/\(|\)//g;
        $line=~s/\[|\]//g;
        $line=~s/\r//g;
				$line=~s/^\s+|\s+$//g;
        $line=~s/\>//g;
        $lcnt++;
	      @tmp=parse_line('\t',0,$line);
        if ($lcnt==1){
          for(my $id=0;$id<=$#tmp;$id++){
            if($tmp[$id]=~/^$i3/){$i1 = $id;}
            if($tmp[$id]=~/^$i4/){$i0 = $id;}
            if($tmp[$id]=~/^$i5/){$i2 = $id;}
          }
        }
        else{
            @name=split(/\;/,$tmp[$i1]);
            foreach (@name) {
                  my $key="$_;$f1";
		              $protein{$key}.="$tmp[$i2];";
                  $nc{"$_"}.="$tmp[$i0];";

            }
        }
    }
    print "$fn;$i2\t";
    close F1;
}
print "ExperimentsDetected\n";

foreach my $g  (keys %nc){
  my $ocg;
	my @ncgt=split(/;|\s+/,$nc{$g});
	my @uniq = do { my %seen; grep { !$seen{$_}++ } @ncgt };
    print "$g\t@uniq\t";
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

perl combineReports.pl november Proteins.txt "Accession" "Description" "Score Sequest HT: Sequest HT" num > combinedReport.txt
