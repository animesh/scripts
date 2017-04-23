use strict;

my $f1 = shift @ARGV;
my $i1 = shift @ARGV;
my $f2 = shift @ARGV;
my $i2 = shift @ARGV;

my @tmp;
my @name;
my %pg;
my %mrna;
my %nc;
my $lcnt;

open (F1, $f1) || die "can't open \"$f1\": $!";
while (my $line = <F1>) {
    $lcnt++;
	@tmp=split(/\t/,$line);
        if ($lcnt>1&&$tmp[$i1]){
 		@name=split(/\;/,$tmp[0]);
 		foreach (@name) { if(!/^(REV|CON)/){$pg{$_}="$tmp[$i1]"; $nc{$_}++;}} 	
        }
}
close F1;
$lcnt=0;

open (F2, $f2) || die "can't open \"$f2\": $!";
while (my $line = <F2>) {
    $lcnt++;
        @tmp=split(/\t/,$line);
        if ($lcnt>1&&$tmp[$i2]){
 		@name=split(/\;/,$tmp[0]);
 		foreach (@name) { $mrna{$_}="$tmp[$i2]"; $nc{$_}++;} 	
        }
}
close F2;

my %cpgn;
my $cp;
my $cm;

foreach my $pgn (keys %pg){
    $cp++;
    $cm=0;
    foreach my $mn (keys %mrna){
	    $cm++;
		if($pgn eq $mn){
		    my $ratio=$pg{$pgn}/$mrna{$mn};
			print "MATCH\t$pgn\t$nc{$mn}\t$pg{$pgn}\t$mrna{$mn}\t$ratio\n";
			$cpgn{$pgn}++;
			#if($nc{$mn}!=2){print "$nc{$mn}\t$nc{$mn}\n";}
		}

    }
    if(!$cpgn{$pgn}){print "MQ1\t$pgn\t$nc{$pgn}\t$pg{$pgn}\n"}
}

foreach  (keys %mrna){
    if(!$cpgn{$_}){print "MQ2\t$_\t$nc{$_}\t$mrna{$_}\n"}
}


print "TOTAL\tMQ1\t$cp\tMQ2\t$cm\n";


__END__

perl mqcomp.pl /cygdrive/c/Users/animeshs/Sissel/Blank/txt/proteinGroups.txt 19 /cygdrive/c/Users/animeshs/Sissel/BlankHL/txt/proteinGroups.txt 23 | grep "^MAT"
