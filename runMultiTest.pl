#!/usr/local/bin/perl

if (! -d "TEST") {
    mkdir("TEST") || die("Cannot create directory TEST: $!\n");
}
open(LOG, ">>runtest.log") || die ("Cannot open runtest.log: $!\n");
print LOG "test readlen spread small_lib large_lib fraction coverage\n";
close(LOG);
my $test = 1;
#foreach $readlen (600, 700, 800, 900) {
#    foreach $spread  (100, 200, 300) {
#	foreach $small  (1500, 2000, 2500, 3000) {
#	    foreach $large  (6000, 8000, 9000, 10000) {
#		foreach $frac  (25, 50, 75) {
# foreach $readlen (800) {
#     foreach $spread (400) {
# 	foreach $small (1500, 2500, 3500, 4500) {
# 	    foreach $large (6000, 8000, 10000) {
# 		foreach $frac (0, 5, 10, 15, 20, 25, 35, 50, 75) {
# 		    foreach $coverage (8) {
foreach $readlen (800) {
    foreach $spread (400) {
	foreach $small (3500) {
	    foreach $large (10000) {
#		foreach $frac (0, 5, 10, 15, 25) {
		foreach $frac (10, 10, 10, 10) {
		    foreach $coverage (6) {
			if (-f "test_$test.qc") {$test++; next;}
			open(LOG, ">>runtest.log") || die ("Cannot open runtest.log: $!\n");
			print LOG "$test $readlen $spread $small $large $frac $coverage\n";
			close(LOG);
			
			if (! -f "$test_$test.conf"){
			    open(TEST, ">test_$test.conf") || die ("Cannot open test_$test.conf: $!\n");
			    print TEST "min_read=", $readlen - $spread / 2, "\n";
			    print TEST "max_read=", $readlen + $spread / 2, "\n";
			    print TEST "\n";
			    print TEST "lib_id=small\n";
			    print TEST "lib_range=$small,", $small + 1000, "\n";
			    print TEST "lib_frac=$frac\n";
			    print TEST "\n";
			    print TEST "lib_id=large\n";
			    print TEST "lib_range=$large,", $large + 2000, "\n";
			    print TEST "lib_frac=", 100 - $frac, "\n";
			    print TEST "\n";
# 			print TEST "genome_file=../n_meningitidis_mc58.1con\n";
#  			print TEST "genome_size=2272351\n";
			    print TEST "genome_file=../na_arm3R_genomic_dmel_RELEASE3.FASTA\n";
			    print TEST "genome_size=27890790\n";
			    print TEST "coverage=$coverage\n";
			    print TEST "seed=", (time ^ ($$ + ($$ << 15))) % 50000,"\n";
			    close(TEST);
			}
			system("cp test_$test.conf TEST");
			chdir("TEST");
			system("/local/asmg/work/mpop/WGA/src/Sim/runTest.pl test_$test.conf");
			chdir("..");
			system("cp TEST/test_$test.qc .");
			system("cp TEST/test_$test.sum .");
			system("cp TEST/test_${test}_1_A00001.frg .");
			system("cp TEST/test_$test.asm .");
			system("rm -rf TEST/*");
			$test++;
		    }
		}
	    }
	}
    }
}
