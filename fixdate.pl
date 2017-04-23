chomp ($d = `date +"%d %B, %Y"`);
$v = pop @ARGV;
while (<>) {
 s/^Version.+/Version~$v, $d/;
 print;
}
