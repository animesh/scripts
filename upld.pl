while(<>){
chomp;
$_=~s/\s+//g;
print "$_\n";
system("wput -B $_ ftp\:\/\/sharma\.animesh\:upLD888\@ftp\.bcgsc\.ca\/incoming\/ga2upload\/");
}

