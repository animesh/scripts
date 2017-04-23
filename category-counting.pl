use strict;
use Text::ParseWords;
my %vh;
my %nh;
my $cntt;

my $f1 = shift @ARGV;
my $id = shift @ARGV;
my $cat = shift @ARGV;
if(!$cat){die "can't open \"$f1\": $! usage:perl category-counting.pl file-name id-column-number category--column-number";}
open(F1,$f1);
while (my $line = <F1>) {
	$line =~ s/\r//g;
	chomp $line;
		my @tmp=parse_line('\t',0,$line);
		$tmp[$cat]=~s/\s+//g;
		$tmp[$id]=~s/\s+//g;
		if($tmp[$cat] eq ""){
					$nh{"NA"}++;
					$vh{"NA"}.="$tmp[$id];";
		}
		else{
			my @tmpp=split(/\;/,$tmp[$cat]);
			for($cntt=0;$cntt<=$#tmpp;$cntt++){
					my ($name)=uc($tmpp[$cntt]);
					#$name=substr($name,0,20);
					$nh{$name}++;
					$vh{$name}.="$tmp[$id];";
			}
		}
	#print "@tmp[0],@tmp[9],@tmpp[0]\n";
}
close F1;

#print "Categories\tcommonID(s)\tID1\tCount1\tID2\tCount2\tCommon\n";
print "Categories\tCount1\tCount2\tCommon\n";
foreach my $k1 (keys %nh){
	foreach my $k2 (keys %nh){
		my @a1=split(/\;/,$vh{$k1});
		my @a2=split(/\;/,$vh{$k2});
		my %h1 = map {$_=>1} @a1;
		my @common = grep { $h1{$_} } @a2; 
		my $c=$#common+1;
		#print "$k1-$k2\t@common\t$vh{$k1}\t$nh{$k1}\t$vh{$k2}\t$nh{$k2}\t$c\n";
		if($c>10){print "$k1-$k2\t$nh{$k1}\t$nh{$k2}\t$c\n";}
		}
}

__END__

perl category-counting.pl /cygdrive/l/Qexactive/Linda/uniprot-tw283.txt 0 9 > t.txt
 
 