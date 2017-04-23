open (F,"testy.txt");
while ($line = <F>)
{	$line=lc($line);
        chomp ($line);
        if ($line =~ /^>/)
        {
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne "")
            {
              push(@seq,$seq);
              $seq = "";
            }
        }
        else
        {
            $seq=$seq.$line;
        }
}
push(@seq,$seq);
$co1=@seq;
foreach $w (@seq){$line=$line.$w;}
@seqfinal=split(//,$line);
print @seqfinal[2];