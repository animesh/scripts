#!/usr/bin/perl

use DBI;

$proc_id = $ARGV[0];
$genseq_id = $ARGV[1];
$proc_stat = $ARGV[2];
$seq_aling = $ARGV[3];

@base=('a','t','g','c') ;

$dbh = DBI->connect('DBI:ODBC:mysql_seqdb', 'root','') or die "Unable to Create DB Handler... \n";

my $insh = $dbh->prepare_cached('INSERT INTO seqfile_seqstring VALUES (?,?,?,?)') or die "Unable to Prepare... \n";


$name = <STDIN>;
chomp($name);
print "The sequence filename is $name \n";

open (FILENAME, $name) || die "can't open $name: $!";

while ($line = <FILENAME>)
    {
    chomp($line);
($seqfile_id,$seq_id,$start_pos,$seq_string) = split(',',$line);
print "$seqfile_id : $seq_id : $start_pos \n";
$insh->execute($seqfile_id,$seq_id, $start_pos,$seq_string)  or die "Unable to Execute... \n";
}


$insh->finish;   


