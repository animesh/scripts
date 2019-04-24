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



