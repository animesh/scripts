use strict;
use warnings;

my $fpat = shift @ARGV;
opendir my $dir, $fpat or die "unable to open directory: $!";
my @files = readdir $dir;
closedir $dir;

my $idn="Accession";
my $idc=0;
my $val=1;

my %mrna;
my %nc;

print "$idn\t";
foreach my $f1 (@files){
    my @tmp;
    my @name;
    my %pg;
    my $fn=$f1;
    $fn =~ s/[^a-zA-Z0-9+]//g;
    if($fn=~/[a-zA-Z0-9+]/){
	    open (F1, "$fpat/$f1") || die "can't open \"$f1\": $!";
	    print "$fn\t";
	    while (my $line = <F1>) {
		$line =~ s/\r//g;
		$line =~ s/\'/-/g;
		$line =~ s/\n/\t/g;
		@tmp=split('\t',$line);
		if($tmp[$idc]=~/^[a-zA-Z0-9+]/){
			my $key="$fn.$tmp[$idc]";
			#if($mrna{$key}<abs($tmp[$val])){$mrna{$key}=$tmp[$val]}
			$mrna{$key}.="$tmp[$val] ";
			$nc{$tmp[$idc]}++;
		}
	    }
	    close F1;
    }
}

print "#file\n";

foreach my $g  (keys %nc){
        print "$g\t";
        foreach  my $f1 (@files){
            my $fn=$f1;
 	    $fn =~ s/[^a-zA-Z0-9+]//g;
	    if($fn=~/[a-zA-Z0-9+]/){
		my $key="$fn.$g";
		print "$mrna{$key}\t";
	    }
        }
        print "$nc{$g}\n";
}


__END__

perl /home/animeshs/misccb/filecombo.pl  directory 2>0 > output
