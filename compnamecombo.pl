use strict;
use Text::ParseWords;

my $f1 = shift @ARGV;
my $fa = shift @ARGV;

my @tmp;
my @name;
my @names;
my %pg1;
my %pgfa;
my %nc;
my $lc;
my $hdr;

open (F1, $f1) || die "can't open \"$f1\": $!";
while (my $line = <F1>) {
	$lc++;
	chomp $line;
	$line =~ s/\r//g;
	@tmp=parse_line(',',0,$line);
	my @slc=@tmp[1..$#tmp];
	if($lc==1){$hdr=join(',',@slc);}
	else{$pg1{$tmp[0]}=join(',',@slc);$nc{$tmp[0]}++;}
}
close F1;

open (FA, $fa) || die "can't open \"$fa\": $!";
while (my $line = <FA>) {
     if ($line  =~ /^>/){
		chomp $line;
		$line =~ s/\r|\>|\=|\,/ /g;
		@tmp=split(/\|/,$line);
		$pgfa{$tmp[1]}="$tmp[2]";
    }
}
close FA;


print "ID,Name,$hdr\n";
foreach my $ncc (keys %nc){
		if($pg1{$ncc}){
			print "$ncc,$pgfa{$ncc},$pg1{$ncc}\n";
		}
}

__END__


perl compnamecombo.pl /cygdrive/X/Qexactive/Linda/MCR7PepWGParse.csv /cygdrive/X/Qexactive/Linda/2013070840IHTU9BBU.fasta > /cygdrive/X/Qexactive/Linda/MCR7PepWGParseName.csv
