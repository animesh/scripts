#! C:/perl/bin/perl

use DBI;


$dbh = DBI->connect('DBI:ODBC:mysql_seqdb', 'root','') or die "Unable to Create DB Handler... \n";

my $insh = $dbh->prepare_cached('INSERT INTO window_analysis VALUES (?,?,?,?,?)') or die "Unable to Prepare... \n";

$process_id =1;
$seqfile_id =1;
$seq_id = 'excluded_4';
$start_pos=1;

$name = <STDIN>;
chomp($name);
print "The sequence filename is $name \n";

open (FILENAME, $name) || die "can't open $name: $!";
$abc = '0';
while ($line = <FILENAME>)
    	{
    	chomp($line);
	($a,$coord) = split(' ',$line);
	$abc = "$abc".",$coord";
#print "$seqfile_id : $seq_id : $start_pos : $a : $b : $c\n";

#$insh->execute($process_id,$seqfile_id,$seq_id, $start_pos,$coord)  or die "Unable to Execute... \n";
}
print $abc;
$insh->execute($process_id,$seqfile_id,$seq_id, $start_pos,$abc)  or die "Unable to Execute... \n";
$insh->finish;   


