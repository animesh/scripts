use strict;
use warnings;
use Text::ParseWords;

my $path = shift @ARGV;
my $pat = "REP";
my $fpat = "proteinGroups.txt";


my $idi = shift @ARGV;
my $i1 = shift @ARGV;
if(!$i1){$i1=20;}
if(!$idi){$idi=7;}

my @files=<$path/*$pat/$fpat>;
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
    	    foreach (@name) {
                my @upid=split(/\|/,$_);
        	my $key=$upid[1].$fn;
                if($tmp[$i1]){$mrna{$key}.="$tmp[$i1] ";}
        	elsif($tmp[$i1+4]==0 && $tmp[$i1+5]==0  ){$mrna{$key}.="Both0 ";}
        	else{$mrna{$key}.="NA($tmp[$i1]-$tmp[$i1-1]) ";} 		
        	$nc{$upid[1]}=$upid[2];
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
