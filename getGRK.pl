$str="MDLQTLNETSVFLECVEAQGAASNGTPNSSLELTNITTCGNAYVVLKPQHVKQKEVDSLRILLYSVIFLLSVFGNLLIIVVLTVNKRMRTVTNSFLLSLAVSDLMMAIFCMPFTLIPNLLEDFIFGPAMCKIVAYLMGVSVSISTFSLVAIAIERYSAICNPLKSRAWQTRSHAYRVITATWLLSFMIMSPYPVFSHLVHVPLKDNITIARMCRHIWPHREVEQTWNMMLLLTLFVVPGVVMIVAYGLISRELYRGIQFELGQKTSSPGLKNGLTGTVSCGSDDGDGCYVQVSKRPHSMEMSTLTSSTASTSKVEHARSNTSEAKLLAKKRVIRMLVVIVALFFLCWMPLYCANTWKAFHPASARRALSGAPISFIHLLSYTSACVNPIIYCFMNTRFRQSLLATFACCCRPPCRHQGLRDGEEDAMALGVSMSKFSYTTVSTMGRAEGGTID";
print length($str),"\n";
$grk="[E|D][S|T][E|D]";
$pka="R[R|K]?[S|T]";
$pkc="[R|K]?[S|T]";
$ngly="[S|T]?N";
$lipd="C???C";
print "CxxxC\n";
$length=5;
while($str =~ /C[A-Z][A-Z][A-Z]C/g)
                                                {
                                                $posi=pos($str);
						$subs=substr($str,$posi-$length,$length);
                                                $posi=($posi-($length))+1;
                                                push(@temp,$posi);
						print "$posi\n$subs\n";
                                                }
print "GRK\n";
$length=3;
while($str =~ /[ED][ST][ED]/g)
                                                {
                                                $posi=pos($str);
						$subs=substr($str,$posi-$length,$length);
                                                $posi=($posi-($length))+1;
                                                push(@temp,$posi);
						print "$posi\n$subs\n";

                                                }

print "PKA\n";
$length=4;
while($str =~ /R[RK][A-Z][ST]/g)
                                                {
                                                $posi=pos($str);
						$subs=substr($str,$posi-$length,$length);
                                                $posi=($posi-($length))+1;
                                                push(@temp,$posi);
						print "$posi\n$subs\n";
                                                }
print "PKC\n";

$length=3;

while($str =~ /[RK][A-Z][ST]/g)
                                                {
                                                $posi=pos($str);
						$subs=substr($str,$posi-$length,$length);
                                                $posi=($posi-($length))+1;
                                                push(@temp,$posi);
						print "$posi\n$subs\n";
                                                }
print "NGly\n";
$length=3;

while($str =~ /[ST][A-Z]N/g)
                                                {
                                                $posi=pos($str);
						$subs=substr($str,$posi-$length,$length);
                                                $posi=($posi-($length))+1;
                                                push(@temp,$posi);
						print "$posi\n$subs\n";
                                                }



