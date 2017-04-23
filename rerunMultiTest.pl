#!/usr/local/bin/perl

# this reruns any .conf file that doesn't have a .qc associated with it.

if (! -d "TEST") {
    mkdir("TEST") || die("Cannot create directory TEST: $!\n");
}

opendir(DOT, ".") || die ("Cannot open current directory: $!\n");
while (my $file = readdir(DIR)){
    if ($file =~ /^(test_\d+).conf/){
	my $test = $1;
	if (! -f "$test.qc"){
	    print "Redoing $1\n";
	    system("cp $test.conf TEST");
	    chdir("TEST");
	    system("/local/asmg/work/mpop/WGA/src/Sim/runTest.pl $test.conf");
	    chdir("..");
	    system("cp TEST/$test.qc .");
	    system("cp TEST/$test.sum .");
	    system("rm -rf TEST/*");	    
	}
    }
}
