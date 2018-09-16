use strict;use warnings;use Text::ParseWords;

my $f=shift @ARGV;my $sep=shift @ARGV;
chomp $f;chomp $sep;

if($sep eq "comma"){$sep=","}
elsif($sep eq "tab"){$sep="\t"}
else{$sep=" "}

if (!$f) {die "\nUSAGE:	\'perl program_name filename_2_b_transposed separator(tab or comma?default space)\'\n\n";}
open F,$f||die"cannot open $f";

my $c1=0;my @mat;my @t;my %rc;
while(my $l=<F>){
	$l =~ s/[\r\n]+$//;
	@t=parse_line($sep,0,$l);
	$rc{$c1}=$#t;
	if($c1>0&&$rc{$c1}!=$rc{$c1-1}){die "elements in row $c1 ($rc{$c1}) not same at first row ($rc{0})"}
	for(my $c2=0;$c2<=$#t;$c2++){
		$mat[$c1][$c2]=$t[$c2];
	}
	$c1++;
}

for(my $c3=0;$c3<=$rc{$c1-$c1};$c3++){
	for(my $c4=0;$c4<$c1;$c4++){
		print $mat[$c4][$c3],$sep;
	}
	print "\n";
}

__END__

for i in *_genus.csv ; do echo $i; perl $HOME/1d/scripts/trp.pl $i tab > $i.trp.txt ; done
