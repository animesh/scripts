use strict;
use Text::ParseWords;

my $f1 = shift @ARGV;
my $f2 = shift @ARGV;
my $f3 = shift @ARGV;
my $f4 = shift @ARGV;
my $fa = shift @ARGV;

my @tmp;
my @name;
my @names;
my %pg1;
my %pg2;
my %pg3;
my %pg4;
my %pgfa;
my %nc;
#check P08729

open (F1, $f1) || die "can't open \"$f1\": $!";
while (my $line = <F1>) {
	chomp $line;
	$line =~ s/\r//g;
	@tmp=split(/,/,$line);
	@tmp=parse_line(',',0,$line);
        if ($tmp[49] =~ /[0-9]/){
 		@name=split(/\;/,$tmp[14]);
 		foreach (@name) { 
 			@names=split(/\-/,$_);
 			$pg1{$names[0]}="$tmp[49]"; $nc{$names[0]}++;	
		#print "$name[$_]\t$tmp[48]\n";
		}
    }
}
close F1;


open (F2, $f2) || die "can't open \"$f2\": $!";
while (my $line = <F2>) {
	chomp $line;
	$line =~ s/\r//g;
	@tmp=split(/,/,$line);
	@tmp=parse_line(',',0,$line);
        if ($tmp[20]  =~ /[0-9]/){
 		@name=split(/\;/,$tmp[0]);
 		foreach (@name) { 
 			@names=split(/\-/,$_);
 			$pg2{$names[0]}="$tmp[20]"; $nc{$names[0]}++; 	
		#print "$_:$pg2{$_}.=$tmp[20]\n";
		}
        }
}
close F2;


open (F3, $f3) || die "can't open \"$f3\": $!";
while (my $line = <F3>) {
	chomp $line;
	$line =~ s/\r//g;
	@tmp=split(/,/,$line);
	@tmp=parse_line(',',0,$line);
        if ($tmp[8] =~ /[0-9]/){
 		@name=split(/\;/,$tmp[0]);
 		foreach (@name) { 
 			@names=split(/\-/,$_);
 			$pg3{$names[0]}="$tmp[8]"; 
 			$nc{$names[0]}++; 	
		#print "$_\t$tmp[8]\n";
		}
     }
}
close F3;

open (F4, $f4) || die "can't open \"$f4\": $!";
while (my $line = <F4>) {
	chomp $line;
	$line =~ s/\r//g;
	@tmp=split(/,/,$line);
	@tmp=parse_line(',',0,$line);
        if ($tmp[4]  =~ /[0-9]/){
 		@name=split(/\;/,$tmp[0]);
 		foreach (@name) { 
 			@names=split(/\-/,$_);
 			$pg4{$names[0]}="$tmp[4]"; $nc{$names[0]}++;	
		#print "$_\t$tmp[4]\n";
		}
    }
}
close F4;

open (FA, $fa) || die "can't open \"$fa\": $!";
while (my $line = <FA>) {
     if ($line  =~ /^>/){
		chomp $line;
		$line =~ s/\r|\>|\=|\,/ /g;
		@tmp=split(/\|/,$line);
		$pgfa{$tmp[1]}="$tmp[2]"; #$nc{$tmp[1]}++;	
    }
}
close FA;


print "Uniprot ID,Name,$f1,$f2,$f3,$f4,#Detected\n";
foreach my $ncc (keys %nc){
		#if($pg1{$ncc} and $pg2{$ncc} and $pg3{$ncc} and $pg4{$ncc}){
		if(($pg1{$ncc} or $pg2{$ncc} or $pg3{$ncc} or $pg4{$ncc}) and $pgfa{$ncc}){
			print "$ncc,$pgfa{$ncc},$pg1{$ncc},$pg2{$ncc},$pg3{$ncc},$pg4{$ncc},$nc{$ncc},\n";
		}
}

__END__

perl mrna-prot-con.pl /cygdrive/c/Users/animeshs/SkyDrive/kamerge/MaxQuantOld.csv /cygdrive/c/Users/animeshs/SkyDrive/kamerge/MaxQuantNew.csv /cygdrive/c/Users/animeshs/SkyDrive/kamerge/1SILAC_LR5_8226_20130416.csv /cygdrive/c/Users/animeshs/SkyDrive/kamerge/list_updown_mrna5.csv /cygdrive/c/Users/animeshs/SkyDrive/kamerge/2013070370GQJPMXGF.fasta > /cygdrive/c/Users/animeshs/SkyDrive/kamerge/merge.csv
