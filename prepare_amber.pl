#!/usr/bin/perl
#
# Devleena Shivakumar, TSRI 05/24/2006.
# 	 Master script to process a multiple ligand mol2 file, usually
#    a DOCK ranked ligands file, and a receptor PDB file into the
#    many pieces needed by DOCK's amber_score.


if ($#ARGV < 1)
{
    print "  Incorrect usage...\n\nCorrect Usage is: ./prepare_amber.pl name_of_DOCK_ranked_mol2_file.mol2   Receptor_PDB_File \n\n";
    exit;
}


########################################################################
### SECTION:1: GENERATES RECEPTOR FILES; CALLS AMBERIZE_RECEPTOR    ####
########################################################################

$rec_pdb_file = $ARGV[1];
if ($rec_pdb_file =~ /(\w+)\.(\w+)/)
{
$rec_file_prefix= $1;
}
open (REC, $rec_pdb_file) || die "\nCannot open Receptor PDB file or it doesn't exist. \nCorrect Usage is:./prepare_amber.pl name_of_DOCK_ranked_mol2_file.mol2 Receptor_PDB_File \n\n";
system "DOCKHOME/bin/amberize_receptor $rec_file_prefix > amberize_rec.out " ;
print("Coordinate and parameter files for the Receptor $rec_file_prefix generated.\n");


########################################################################
### SECTION:2: ADDS THE <@TRIPOS> TAG AT THE END OF EACH MOL2 FILE####
########################################################################

my($mol2_file) = "";
my($global_count) = 0;
my($local_count) = 0;

chomp ($mol2_file = $ARGV[0]);
open (MOL2, $mol2_file) || die "\nCannot open mol2_file '$mol2_file' or it doesn't exist. \nCorrect Usage is: ./prepare_amber.pl name_of_DOCK_ranked_mol2_file.mol2 Receptor_PDB_File \n\n";

# assign basename for output files based on input MOL2 filename:
if ($mol2_file =~ /(\w+)\.(\w+)/) { $prefix = $1 ; }
        else { $prefix = $mol2_file."_"; }

open (OUT, ">$prefix.amber_score.mol2") || die "\nCannot open output MOL2 filename \"$prefix.amber_score.mol2\" for writing.\n\n";

while (<MOL2>)
{
        chomp($_);


        if ($_ =~ /^(@<TRIPOS>MOLECULE)/)
        {
                if( $local_count != 0 )
                {
                    print OUT "@<TRIPOS>AMBER_SCORE_ID\n";
                    print OUT "$prefix.$global_count\n\n\n";
                }

                print OUT "$_\n";

                $local_count++;
                $global_count++;
        }

        if ($_ =~ /^(@<TRIPOS>MOLECULE)/ && $local_count > 1)
        {
                $local_count = 1;
                next;
        }


        if ($_ !~ /^(@<TRIPOS>MOLECULE)/ && $_ !~ /^(#######)/ && $local_count == 1 )
        {
               print OUT "$_\n" ;
               next;
        }

}
print OUT "@<TRIPOS>AMBER_SCORE_ID\n";
print OUT "$prefix.$global_count\n\n\n";
print OUT "$_\n";

print("The AMBER score tagged mol2 file $prefix.amber_score.mol2 generated.\n");


########################################################################
### SECTION:3: SPLITS MULTIPLE.MOL2 INTO INDIVIDUAL MOL2 FILES      ####
########################################################################

print("Splitting the multiple Ligand mol2 file into single mol2 files.\nThe single mol2 files will have the prefix: $prefix \n");
my($mol2_file) = "";
my($global_count) = 0;
my($local_count) = 0;

$mol2_file = $ARGV[0];
open (MOL2,  $mol2_file) || die "\nCannot open mol2_file '$mol2_file' or it doesn't exist. \nCorrect Usage is: ./prepare_amber.pl name_of_your_DOCK_ranked_mol2_file.mol2 \n\n";

# assign basename for output files based on input MOL2 filename:

while (<MOL2>)
{
        chomp($_);
               if ($_ =~ /^(@<TRIPOS>MOLECULE)/)
        {
	$global_count++;
	open (OUT, ">$prefix.$global_count.mol2") || die "\nCannot open output MOL2 filename \"$prefix.amber_score.mol2\" for writing.\n\n";
		print OUT "$_\n";
                $local_count++;

        }

        if ($_ =~ /^(@<TRIPOS>MOLECULE)/ && $local_count > 1)
        {
                $local_count = 1;
                next;
        }

	if ($_ !~ /^(@<TRIPOS>MOLECULE)/ && $_ !~ /^(#######)/ && $local_count == 1 )

	{

		print OUT "$_\n" ;
                next;
        }
}
close OUT;


################################################################################
### SECTION:4: GENERATE FILES FOR LIGAND AND COMPLEX; CALL AMBERIZE SCRIPTS ####
################################################################################

print("Generating coordinate and parameter files with AM1-BCC charges.\nThis may be time consuming.\n") ;
for ($lignum = 1; $lignum <= $global_count; $lignum++)
{
	$count = 1;
	$sum1 = 0;
	open(smol2, "$prefix.$lignum.mol2") || die "\nCannot open Mol2 file $prefix.$lignum.mol2\n\n";
	while(<smol2>)
	{
#        next unless /@<TRIPOS>ATOM /;
        	@s = split ' ', $_;
        	$col{$count} = $s[8];
        	$sum1 += $col{$count};
        	$count++;
        	$sum = round ($sum1);
	}
	print("Ligand $prefix.$lignum has total charge $sum\n");
	system "DOCKHOME/bin/amberize_ligand $prefix.$lignum $sum 1> amberize_ligand.$lignum.out 2>&1 ";
	print("Coordinate and parameter files for the Ligand $prefix.$lignum generated.\n");
	system "DOCKHOME/bin/amberize_complex $rec_file_prefix $prefix.$lignum 1> amberize_complex.$lignum.out  2>&1" ;
	print("Coordinate and parameter files for the Complex $rec_file_prefix.$prefix.$lignum generated.\n");
}

print("$0 completed.\n") ;


sub round

{
	my($sum1) = shift;
	return int($sum1 + 0.5 * ($sum1 <=> 0));
}

exit;

