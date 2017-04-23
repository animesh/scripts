#!/usr/bin/perl -w

if($#ARGV<0){
    print "\n";
    print "[USAGE:]\n\n";
    print "      $0 RDOCK_output_file\n\n";
    print "      This program gives RDOCK ranks for each ZDOCK prediction.\n\n";
    exit;
}

open RDOCK, "$ARGV[0]";

%energy=();
($index,$elec_first,$vdw_first,$ace_first,$elec_second,$vdw_second,$ace_second)=();
$i=0;
foreach (<RDOCK>){
    if($i==0){$i++;next;}
    chomp;
    @split=split;
    if ($#split != 6){
	printf STDERR "Wrong format in line ", $i+1, "\n";
	$i++;
	next;
    }
    ($index,$elec_first,$vdw_first,$ace_first,$elec_second,$vdw_second,$ace_second)=split;
    if($index != $i){
	print STDERR "Number in line [",$i+1,"] doesn't match with index in file $ARGV[0].\n";}

    if($ace_first eq "---" || $ace_second eq "---"){
	$energy=99999;
    }
    elsif($vdw_first>=100){
	$energy=99999;
    }
    else{
	$energy=$elec_second+$ace_first*0.67;
    }
    $energy{$index}=$energy;
    $i++;
}

@sort_energy=sort {$energy{$a} <=> $energy{$b};} keys %energy;

print "RDOCK\tZDOCK\n";

#print out zdock ranks sorted by rdock energy
$i=1;
foreach $index (@sort_energy){
    print "$i\t$index\n";
    $i++;
}
		     
