#!/usr/bin/perl
use lib "/scratch/bioperl/";
@organism=qw/chick	danre	fugu	mouse	xentr	bovin	ptro	macaca/;

foreach $org (@organism) {
	print "Org- $org\t";
	$filein="align2d_".$org.".py";
	system("mod9v3 $filein");
	print "Finish Prog - align2d\t";
	$filein="model-single_".$org.".py";
	system("mod9v3 $filein");
	print "Finish Prog - model-single\n";
}

foreach $org (@organism) {
	print "Org- $org\t";
	for($n=1;$n<6;$n++) {
		$filein="evaluate_model_".$org."_$n.py";
		print "ModelNumber - $n\t $filein\n";
		system("mod9v3 $filein");
	}
	print "Org- $org Done\n";
}

