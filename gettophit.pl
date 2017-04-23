$main_file_pattern=shift @ARGV;
chomp $main_file_pattern;
open(F,$main_file_pattern)||die "can't open";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
		$snames=$line;
		chomp $snames;
        	@ty=split(/\s+/,$snames);
        	push(@seqname,@ty[0]);
                if ($seq ne ""){
              	push(@seq,uc($seq));
              	$seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,uc($seq));
$seq="";
close F;

$list_file_pattern=shift @ARGV;
chomp $list_file_pattern;
open(FF,$list_file_pattern)||die "can't open";
while ($line = <FF>) {
        chomp ($line);
	@ty=split(/\s+/,$line);
	push(@list,@ty[0]);
}
close FF;

my $fresall=$main_file_pattern.$list_file_pattern.".s2g.txt";
open(FRA,">$fresall");
for($f=0;$f<=$#list;$f++){
for($fot=0;$fot<=$#seq;$fot++){
@seqname[$fot]=~s/\>|\s+//g;
lc(@seqname[$fot]);
@list[$f]=~s/\s+//g;
lc(@list[$f]);
if(@list[$f] eq @seqname[$fot]){
print "@seqname[$fot]\t@list[$f]\n";
$Seqname.=@seqname[$fot];
$Seq.=@seq[$fot];
}
else{
next;
}
}
}
print FRA">$Seqname\n$Seq\n";
close FRA;

