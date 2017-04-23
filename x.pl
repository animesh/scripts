@x=qw/a s d f/;
print "$x[0]\n\n";
foreach $x (@x)
{
print "$x\n";
$s="aassasddfffsdsdsasa";
foreach $sn (split(//,$s))
{
$d=$s.$sn;
print "$sn";
}
print "$d\n";
}
