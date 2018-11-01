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
