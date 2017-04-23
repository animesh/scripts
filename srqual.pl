while(<>){
$line++;
@tmp=split(/\t/);
$readval{@tmp[0]}=@tmp[12]+0;
}
foreach $read (sort {$readval {$b} <=> $readval {$a}} keys %readval ){ 
	#print "$read\t$readval{$read}\n";
	print "$read\n";
}

