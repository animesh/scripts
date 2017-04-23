while(<>){
	split(/\t/);
	if(@_[5]>@_[6]){$s=@_[6];$e=@_[5];print "Rev\t"}
	else{$s=@_[5];$e=@_[6];}
	#for($c=$s;$c<=$e;$c++){
		#push(@pos,$c);
		#print "$c\n";
		$pos{$c}++;
	#}
	print "@_[4]>@_[7]\t@_[5]>@_[6]\n";
}
#foreach (keys %pos) {print "$_\t$pos{$_}\n";}
__END__
for($c=0;$c<=$#pos;$c++){
	print "@pos[$c]";
}

