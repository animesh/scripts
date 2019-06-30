my %twoBit = ('T' => 0b00,'C' => 0b01,'G' => 0b10,'A' => 0b11, 0b00 => 'T',0b01 => 'C',0b10 => 'G',0b11 => 'A');
my $fasta='TATAA';
print $fasta. length( $fasta ) . "\n";

sub compress2bit{
  my $fasta=shift;
  my @bases = split //, $fasta;
  my $bits = '';
  for my $i ( 0 .. $#bases ) {vec( $bits, $i, 2 ) = $twoBit{ $bases[$i] };}
  return $bits;
}

sub expand2bit{
  my $bits=shift;
  print unpack("b*",$bits), "\n";
  my $strings = '';
  for my $i (0 .. oct("0b" . unpack("%0b2",$bits))-1){$strings.=$twoBit{vec($bits,$i,2)};}
  #print $bits. length($bits) . "\n";
  return $strings;
}

my $strs=compress2bit($fasta);
#print $strs. length($strs) . "\n";

my $exstrs=expand2bit($strs);
print $exstrs. length($exstrs) . "\n";

__END__
use strict;
use warnings;
use Math::BigFloat lib => 'GMP';

#Accuracy upto 100th number

my $levelacc=100;
my $x1=Math::BigFloat->new(-1);
my $x2=Math::BigFloat->new(-1.57);
my $x3=Math::BigFloat->new(-113.1);
my $L1=$x1->bexp($levelacc);
my $L2=$x2->bexp($levelacc);
my $L3=$x3->bexp($levelacc);
my $sum1=($L1);
my $sum2=($L1+$L2);
my $sum3=($L1+$L2+$L3);
print "$L1,$L2,$L3\t$sum1\t$sum2\t$sum3\n";

#Normal Way
$L1=exp(-1);
$L2=exp(-1.57);
$L3=exp(-113.1);
$sum1=($L1);
$sum2=($L1+$L2);
$sum3=($L1+$L2+$L3);
print "$L1,$L2,$L3\t$sum1\t$sum2\t$sum3\n";


chomp($var=shift @ARGV);
 open(PS_F, "ps -fa|");
 while (<PS_F>) {
 ($uid,$pid,$ppid,$c,$stime,$tty,$time,$cmd,$restOfLine) = split;
 #print "$uid,$pid,$ppid,$c,$stime,$tty,$time,$cmd\n$var";
 if ($cmd eq $var){system("kill -9 $pid");}
 }
 close(PS_F);

#!/usr/bin/perl
$testseq="atatatattt";
$k="atatat";
print "$testseq\n$k\n";
#if($testseq =~ /$k/g)
#{
	while($testseq =~ /$k/g)
		{
        $position=pos($testseq);
        #print "$position \n";
        #pos($testseq)=0;
        }
		#}
@test2=qw/w e r t/;
$t=\@test2;
#print "@$t\n";
for($c=0;$c<10;$c++)
{	@test1=qw/r t y u/;
	$test{$c}=@$t[0..(-2)];
}
foreach $w (keys %test) {
	print "$test{$w}\n";
}
#$len=length($testseq);
#$subs=substr($testseq,0,6);
#print "$subs\n$len\n";

while(<>){
	chomp;split(/\s+/);
	#print "@_[0]\n";
	push(@posi,@_[0]);
}
for($c=0;$c<=$#posi;$c++){
	if(@posi[$c+1]-@posi[$c]!=1){
		$start=@posi[$c]-$cnt;
		print "$start\t$cnt\t@posi[$c]\n";
		#print "     COD	     $start..@posi[$c]\n";
		$cnt=0;
	}
	elsif(@posi[$c+1]-@posi[$c]==1){
		$cnt++;
	}
}



#!/usr/bin/perl
system "ls -1>tempfile.perl";
open F,"tempfile.perl";
while ($l=<F>)
{
chomp $l;
push(@NAMES,$l);
}
print "pw,\<matrixname\>,\<matrix name\>,1,pwmatrix,S\n";
foreach $n (@NAMES)
{
$nn=$n;
print " ,$nn,$nn, , , \n";

}
unlink "tempfile.perl";


if( @ARGV ne 1){die "\nUSAGE\t\"ProgName SeqFile\t\n\n\n";}
$file1 = shift @ARGV;
open (F, $file1) || die "can't open \"$file1\": $!";
$seq="";
while ($line = <F>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		push(@seqname1,$line);
		if ($seq ne ""){
			push(@seq1,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq1,$seq);
close F;
$per=10;
@base=qw/A T G C/;
#open(FT,">$file1.errinj");
for($c1=0;$c1<=$#seq1;$c1++){
	$len=length($seq1[$c1]);
	$toterr=int($len*$per/100);
	$errornum=int(rand($toterr));
	while($errornum>0){
		$errornum--;
                $pcl = int(rand($len));
                #$pcl = int(gaussian_rand()*$len);
		substr($seq1[$c1], $pcl, 1) = "$base[int(rand(4))]";
	}
	print "$errornum-$pcl-$c1-$per-$toterr-$len-$seqname1[$c1]\n";
	#print FT"$seqname1[$c1]\n$seq1[$c1]\n";

}
#close FT;

sub gaussian_rand {
    my ($u1, $u2);  # uniformly distributed random numbers
    my $w;          # variance, then a weight
    my ($g1, $g2);  # gaussian-distributed numbers

    do {
        $u1 = 2 * rand() - 1;
        $u2 = 2 * rand() - 1;
        $w = $u1*$u1 + $u2*$u2;
    } while ( $w >= 1 );

    $w = sqrt( (-2 * log($w))  / $w );
    $g2 = $u1 * $w;
    $g1 = $u2 * $w;
         return wantarray ? ($g1, $g2) : $g1;
}

#!/usr/bin/perl
print "\n---The Answer Lies In The Genome---\n";
system("fortune");

while(<>){
chomp;
$c++;
$_=~s/\s+||\"//g;
if($c%3==0){print "$_\n";}
else{print "$_,";}
}

#!/usr/bin/perl
open(F,"cnall.txt");
$out="cnallformatted.txt";
while ($line = <F>) {
        #chomp ($line);
	$line=~s/\s+/ /g;
	@t1=split(/ /,$line);
	$t2=@t1[2];
	push(@list,$t2);
}
	%seen=();
	@combos = grep{ !$seen{$_} ++} @list;
foreach $t3 (@combos)
	{
	print "$t3\n"
	}
close F;

#$c=shift @ARGV;

print rec(10);

sub rec {
    $c=shift;
    chomp $c;
	while($c>=0){
	    $t=recur($c);
	    print "Term $c => $t\n";
	    $c--;}
    sub recur{
	my $n=shift;
	if($n==1){return 1;}
	elsif($n<1){return 0;}
	else{return(recur($n-1)+recur($n-2))};
    }
}

sub ite{
    $c=shift;
    chomp $c;
    iter($c);
    sub iter{
	$x1=0;
	$x2=1;
	for($i=0;$i<$c;$i++){
	    print "$x1\n";
	    ($x1,$x2)=($x1+$x2,$x1);
	}
    }
}

sub factorial {
    my $number = shift @_;
    return undef if $number < 0; # illegal value
    return 1 if $number == 0;

    my $factorial = 1;
    for (my $i = $number; $i > 1; $i--) {
	$factorial = $factorial * $i;
    }
    return $factorial;
}
Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

sub factorial {
    my $number = shift @_;
    return undef if $number < 0; # illegal value
    return 1 if $number == 0;

    return( $number * factorial($number -1) );
}
