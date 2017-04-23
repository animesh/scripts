while(<>){
	chomp;
	@t=split(/\s+/,$_);
	if(@t[3] ne "NA" and @t[4] ne "NA" and @t[3] ne "" and @t[4] ne ""){
		$c++;
		$name_gene="\$MIRA$c";
		print "\tmy $name_gene = \$ftr->new(-start=>@t[3],-end=>@t[4]);\n";
		push(@name,$name_gene);
	}

}
print "\tmy \$t = \$panel->add_track(\n";
print "\t\ttranscript => [\n";
for($c=0;$c<$#name;$c++){
	print "@name[$c],";
}
print "@name[$c]";

print "],\n\t\t-label => 1,\n\t\t-bump => 1,\n\t\t-bgcolor => 'blue',\n\t\t-key => 'MIRA',\n\t\t);\n";
