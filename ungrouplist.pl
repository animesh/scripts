use strict;
use warnings;
use Text::ParseWords;

my $path = shift @ARGV;
my $idi = shift @ARGV;
my $val = shift @ARGV;
my %nc;
my $lcnt;

open (F1, $path) || die "can't open \"$path\": $!";
while (my $line = <F1>) {
        chomp $line;
        my $cl=$line;
        $line =~ s/\r|\`|\"|\'/ /g;
        $lcnt++;
    	my @tmp=parse_line('\t',0,$line);
        if ($lcnt>1){
            my @name=split(/\;/,$tmp[$idi]);
    	    foreach (@name) {
        	#$nc{$_}=$cl;
        	$nc{$_}=$tmp[$val];
    	    }
        }
}
close F1;

foreach my $g  (keys %nc){
    if($g ne "" and $nc{$g}>=1){
        print "$g\t$nc{$g}\n";
    }
    elsif($g ne "" and $nc{$g}>0){
        print "$g\t",-1/$nc{$g},"\n";
    }
    elsif($g ne ""){
        print "$g\t \n";
    }
}


__END__

perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 12 50 2>err > /cygdrive/l/Elite/kamila/proteinGroupsOdenseGNUG.txt


