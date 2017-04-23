open f,"est1.txt";
while($line=<f>)
{
#chomp $line;
@rr=split(" ",$line);
if(@rr[1] =~ /[0-9]/)
{
print "$line\n";

#print @rr;
undef @rr;
@rr="";
#print "\n";
}
}
