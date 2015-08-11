@files=<ung2*xml>;
for($c=0;$c<=$#files;$c++){
	print "$files[$c]\n";
	open(F,">$files[$c].mgf");
	print F"BEGIN IONS\nPEPMASS=3467\nCHARGE=1+\n";
	system("grep \"<mass>\" $files[$c] | sed -r \'s/<|>/ /g\' | awk '{print \$2}' > tm");
	system("grep \"<absi>\" $files[$c] | sed -r \'s/<|>/ /g\' | awk '{print \$2}' > ti");
	system("paste -d \"\t\" tm ti >> $files[$c].mgf ");
	system("echo \"END IONS\" >> $files[$c].mgf ");
	close F;
}