use strict;
use warnings;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = "REP";
my $fpat = "proteinGroups.txt";


my $idi = shift @ARGV;
my $idn = shift @ARGV;
my $i1 = shift @ARGV;
my $thr = shift @ARGV;

if(!$i1){$i1=18;}
if(!$idi){$idi=0;}
if(!$idn){$idn=17;}
if(!$thr){$thr=1000;}

#my @files=<$path/*$pat/$fpat>;
my @files=</mnt/f/20210118_8samples/mqpar.xml.1611245625.results/*/*/txt/prot*>;
#my @files=<*.txt>;
my %mrna;
my %nc;

print "Uniprot ID\tID Name\t";
foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $lcnt;
    my $fn=$f1;
    $fn=~s/$path|$pat|$fpat|\///g;
    print "$fn\t";
    open (F1, $f1) || die "can't open \"$f1\": $!";
    while (my $line = <F1>) {
        chomp $line;
        $line =~ s/\r|\`|\"|\'/ /g;
        $lcnt++;
    	@tmp=parse_line('\t',0,$line);
        if ($lcnt>1){
            @name=split(/\;/,$tmp[$idi]);
            #@name=split(/\t/,$tmp[$idi]);
    	    foreach (@name) {
            my @upid=split(/\|/,$_);
			$upid[1]=$_;
        	my $key=$upid[1].$fn;
            if($tmp[$i1]>$thr){$mrna{$key}.="$tmp[$i1] ";}
        	elsif($tmp[$i1+2]>$thr){$mrna{$key}.="$tmp[$i1+2] ";}
        	elsif($tmp[$i1+12]>$thr){$mrna{$key}.="$tmp[$i1+12] ";}
        	else{$mrna{$key}.="NA";}
        	$nc{$upid[1]}=$tmp[6];
    	    }
        }
        #if ($lcnt==1){print "$f1\t$fn\n";}
    }
    close F1;
}
print "TotalDetect\n";

foreach my $g  (keys %nc){
    if($g ne ""){
        my $ocg;
        print "$g\t$nc{$g}\t";
        foreach  my $f (@files){
            $f=~s/$path|$pat|$fpat|\///g;
        	my $key=$g.$f;
        	print "$mrna{$key}\t";
        	if($mrna{$key}=~/[0-9]/){$ocg++;}
        }
        print "$ocg\n";
    }
}


__END__

#perl /cygdrive/c/Users/animeshs/misccb/mqpevol.pl /cygdrive/j/MSdata 7 20 2>0 > combo.txt
perl mqpevol.pl  /cygdrive/i/MQResults/CellLines/ 2>0 >  /cygdrive/i/MQResults/CellLines/combo.txt
