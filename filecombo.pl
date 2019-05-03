use strict;
use Spreadsheet::Read;
my $id=0;
my %vh;
my %nh;
my %ch;

sub createhash{
	my $f1 = shift;
	my $data  = ReadData ($f1);
	my @lin=cell2cr($data->[1]{cell}[1][3]);#->[1]{$c};
	my $line;
	my $lc;
	print "$f1\t$data\n";
	#for(my $c=0;$c<=$#data;$c++){
	for(my $c=0;$c<=10;$c++){
		$lc++;
		#$lc=$lin[1][1];
		$line =~ s/\r//g;
		chomp $line;
		print "@lin\t";
		if($lc==1){$vh{$f1}="$line";}
		else{
			my @tmp;#=parse_line(',',0,$line);
			if ($tmp[$id] ne ""){
				$nh{$tmp[$id]}++;
				$ch{"$tmp[$id]-$f1"}++;
				$vh{"$tmp[$id]-$f1"}=$line;
			}
		}
	}
}

for(my $c=0;$c<=$#ARGV;$c++){
	my $fn=createhash($ARGV[$c]);
}


my $lc;

#print "ID,Total,";
for(my $c=0;$c<=$#ARGV;$c++){
	#print "$vh{$ARGV[$c]},InFile,";
}
#print "Total\n";

foreach my $ncc (keys %nh){
	$lc++;
	print "$ncc,$nh{$ncc},";
	for(my $c=0;$c<=$#ARGV;$c++){
		my $name="$ncc-$ARGV[$c]";
		print "$vh{$name},$ch{$name},";
	}
	print "$nh{$ncc}\n";
}

__END__

$ perl filecomb.pl /cygdrive/l/Elite/gaute/HAMR/hamrcomb.xls /cygdrive/l/Elite/gaute/HAMR/hamrcomb.txt /cygdrive/l/Elite/gaute/HAMR/hamrcomb.csv /cygdrive/l/Elite/gaute/HAMR/hamrcomb.xlsx
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.xls       ARRAY(0x6018b5d18)
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.txt
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.csv       ARRAY(0x6027d4828)
/cygdrive/l/Elite/gaute/HAMR/hamrcomb.xlsx      ARRAY(0x6022084d8)
ID,Total,,InFile,,InFile,,InFile,,InFile,Total

