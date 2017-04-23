use strict;
#use warnings;

#Simulate circular genome of length $seqlen
sub genseq{
	my $seqlen=shift;
	my $c=0;
	my $seq;
	my @b=qw/A T G C/;
	#my @b=qw/A C A C/;
	my $sn=">Seq$seqlen";
	while($c<$seqlen){
		$seq.=@b[int(rand(4))];
		$c++; 
	}
	print "Simulated Genome $seq\n";
	return($sn,$seq);
}

#Split simulated sequence in $len k-mers reads with $ovl overlap reflecting sum of read length as a multiple of $cov coverage and length of simulated genome $seqlen
sub splitseq{
	my $seq=shift;
	my $len=shift;
	my $cov=shift;
	my $ovl=shift;
	my $cnt=0;
	my $slen=length($seq);
	my @seqscoll;
	for(my $c=0;$c<$cov*$slen*($len-$ovl)/$len;$c+=($len-$ovl)){
		my $ss=substr($seq,($c)%($slen),$len);
		if($c%$slen+$len>$slen){$ss.=substr($seq,0,($c+$len)%$slen)}
		$cnt++;
		push(@seqscoll,$ss);
	}
	print "Generated k-mers ",join(" ",@seqscoll),"\n";
	return(\@seqscoll);
}

#Search (waiting to be completed!)
sub breadth{
           my $reads = shift;
           my @read = @$reads;
           while(scalar(@read) > 0){
                 my @t;
                 foreach my $r (@read){
                       print $r."\n";
                       my ($con,$r)=get_con($r);
                       map { &proc_con($_);} @$con;
                       push @t, @$r;
                 }
                 @read = @t;
            }
     }


#Calling routing to simulate genome
my $fg="Genome.L$ARGV[0].K$ARGV[1].C$ARGV[2].O$ARGV[3].fa";
open(FG,">$fg");
my ($sn,$seq)=genseq($ARGV[0]);
print FG"$sn\n$seq\n";
close FG;

#Calling routine to generate reads from the simulated genome
my $seqs=splitseq($seq,$ARGV[1],$ARGV[2],$ARGV[3]);

#Comparing reads against each other to find perfect match (very restricted version of read alignment ;)
my @seqsc=@$seqs;
my $fo="Genome.L$ARGV[0].K$ARGV[1].C$ARGV[2].O$ARGV[3].cg";
open(FO,">$fo");
my %exist = ();
my @seqscu = grep { ! $exist{$_} ++ } @seqsc;
for(my $c1=0;$c1<=$#seqscu;$c1++){
	print FO"$seqscu[$c1]";
	#print FO"$seqsc[$c1-1]\t";
	for(my $c2=0;$c2<=$#seqsc;$c2++){
		if($seqscu[$c1] eq $seqsc[$c2]){
			#print "$c1\t$seqsc[$c1]\t$c2\t$seqsc[$c2]\n";
			print FO" $seqsc[$c2+1]";
			#print FO"\t$seqsc[$c2-1]\t";
		}
	}
	print FO"\n";
}
close FO;
print "Genome file $fg\nConnectivity file $fo\nRunning shell Hamiltonian path finder and writing output to $fo.ham\n";
system("bash ham.sh < $fo > $fo.ham");
print "Collapsed ham.sh output from $fo.ham written to $fg.ham\n";
open(FH,"$fo.ham");
open(FHW,">$fg.ham");
my $sgh;
while(<FH>){
	chomp;
	my @th=split(/\s+/);
	$sgh=$th[0];
	for(my $ch=1;$ch<=$#th;$ch++){
		$sgh.=substr($th[$ch],$ARGV[3],$ARGV[1]-$ARGV[3]);
	}
	if(length($sgh)>$ARGV[0]){$sgh=substr($sgh,0,$ARGV[0]);}
}
print "Assembled Genome $sgh\n";
print FHW">HamStringGenome\n$sgh\n";
close FHW;
close FG;

