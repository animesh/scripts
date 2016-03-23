use strict;
use Text::ParseWords;
my %vh;
my %nh;
my %gh;
my $cnt=0;
my $idcnt=0;
my $cntt;
my $category;
my $ID;
my $f1 = shift @ARGV;
my $id = shift @ARGV;
my $idg = shift @ARGV;
my $cat = shift @ARGV;
my $valchk = shift @ARGV;
my $thr = shift @ARGV;

open(F1,$f1);
while (my $line = <F1>) {
	chomp $line;
	$line =~ s/\r|\'|\"//g;
	my $emptytest=$line;
	$emptytest =~ s/[^a-zA-Z0-9]*//g;
	$emptytest =~ s/\s+//g;
	if($emptytest ne ""){
		my @tmp=parse_line('\t',0,$line);
		$tmp[$cat]=~s/^\s+//g;
		$tmp[$cat]=~s/\s+$//g;
		$tmp[$id]=~s/\s+//g;
		my ($idd)=uc($tmp[$id]);
		if($cnt<1){
			$category=$tmp[$cat];
			$ID=$tmp[$id];
		}
		elsif(($thr<0&&$tmp[$valchk]<0)||($thr>0&&$tmp[$valchk]>0)||($thr eq "" && $tmp[$valchk] ne "")){$idcnt+=1;
			if($tmp[$cat] eq ""){
						$nh{"NA"}++;
						$vh{"NA"}.="$idd;";
			}
			else{
				my @tmpp=split(/\;/,$tmp[$cat]);
				for($cntt=0;$cntt<=$#tmpp;$cntt++){
						$tmpp[$cntt]=~s/^\s+//g;
						$tmpp[$cntt]=~s/\s+$//g;
						my ($name)=uc($tmpp[$cntt]);
						$nh{$name}++;
						$vh{$name}.="$idd;";
						$gh{$name}.=uc($tmp[$idg]),";";
				}
			}
		}
		$cnt++;
	}
}
$cnt--;
close F1;

print "$category\t$ID\tUnique\tGene\tCountAll\tCountUnique\tSelect-Total\n";
foreach my $k (keys %nh){
	my @a=split(/\;/,$vh{$k});
	my @au = do { my %seen; grep { !$seen{$_}++ } @a };
	my @b=split(/\;/,$gh{$k});
	my @bu = do { my %seen; grep { !$seen{$_}++ } @b };
	my $c=$#au+1;
	print "$k\t$vh{$k}\t@au\t@bu\t$nh{$k}\t$c\t$idcnt-$cnt\n";
}

__END__

$ perl remove-duplicate-rows.pl /cygdrive/y/felles/PROTEOMICS\ and\ XRAY/Articles\ in\ prep/AID/IP/UPpv5pGO.tab > /cygdrive/y/felles/PROTEOMICS\ and\ XRAY/Articles\ in\ prep/AID/IP/UPpv5pGO.tab.rd.txt

$ perl category-counting-with-ID.pl /cygdrive/y/felles/PROTEOMICS\ and\ XRAY/Articles\ in\ prep/AID/IP/UPpv5pGO.tab.rd.txt 0 2 9 > /cygdrive/y/felles/PROTEOMICS\ and\ XRAY/Articles\ in\ prep/AID/IP/UPpv5pGO.rd.BP.txt

