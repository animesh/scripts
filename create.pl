#!/usr/local/bin/perl

# Rong Chen 6/24/2002

if ($#ARGV != 0)
{
    print "This program creates all predicted complex structures ";
    print "according to a zdock output. ";
    print "create_lig, receptor.pdb, and ligand.pdb must be in your current directory.\n";
    print "\nUsage:\n";
    print "$0 [dock.out]\n\n";
    die;
}

$spacing=1.2;
open (FDOCK, "<$ARGV[0]") || die "\nCannot open file $ARGV[0]!\n\n";
@line = <FDOCK>;
chomp(@line);
($n, $spacing)=split(" ", $line[0]);
($rand1, $rand2, $rand3)=split(" ", $line[1]);
($rec, $r1, $r2, $r3) = split (" ", $line[2]);
($lig, $l1, $l2, $l3) = split (" ", $line[3]);
close FDOCK;

for ($i = 4; $i < @line; $i++){
    ($angl_x, $angl_y, $angl_z, $tran_x, $tran_y, $tran_z, $score)
       = split ( " ", $line[$i] );
    $number = $i-3;
    system "./create_lig $lig.$number $lig $rand1 $rand2 $rand3 $r1 $r2 $r3 $l1 $l2 $l3 $angl_x $angl_y $angl_z $tran_x $tran_y $tran_z $n $spacing\n";
    system "cat $rec $lig.$number > complex.$number\n";
    system "rm $lig.$number\n";
}
