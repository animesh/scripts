#!/usr/bin/perl

use AMOS::AmosLib;

$frgfile = $ARGV[0];
$listfile = $ARGV[1];
$incl = $ARGV[2];

if (! defined $incl){
	print STDERR "Will include the sequences in $listfile\n";
	$include = 1;
} else {
	print STDERR "Will exclude the sequences in $listfile\n";
	$include = 0;
}

open(LIST, $listfile) || die ("Cannot open \"$listfile\"\n");
while (<LIST>){
    chomp;
    $in{$_} = 1;
}
close(LIST);

open(FRG, $frgfile) || die ("Cannot open $frgfile\n");

my $isAMOS = 1;

my %srcid;
while ($record = getRecord(\*FRG)){
    my ($rec, $fields, $recs) = parseRecord($record);
    if ($rec eq 'BAT'){
	$isAMOS = 0;
    }
    if ($isAMOS == 0){
	my $src = $$fields{src};
	@src = split('\n', $src);
	$src = join('', @src);
	$srcid{$$fields{acc}} = $src;
	if ($rec eq "FRG"){
	    if ($include && (exists $in{$$fields{acc}} || exists $in{$src})){
		print $record;
	    } elsif (! $include && ! (exists $in{$$fields{acc}} || exists $in{$src})){
		print $record;
	    }
	    if (! $include && (exists $in{$$fields{acc}} || exists $in{$src})){
		print STDERR "excluding $$fields{acc}($src)\n";
	    }
	    next; 
	}
	if ($rec eq "LKG"){
	    if ($include){
		if ((exists $in{$$fields{fg1}} || exists $in{$srcid{$$fields{fg1}}})
		    && (exists $in{$$fields{fg2}} || exists $in{$srcid{$$fields{fg2}}})){
		    print $record;
		}
	    } else {
		if (! (exists $in{$$fields{fg1}} || exists $in{$srcid{$$fields{fg1}}}) 
		    && ! (exists $in{$$fields{fg2}} || exists $in{$srcid{$$fields{fg2}}})){
		    print $record;
		}
	    }
	    next;
	}
    } elsif ($isAMOS == 1){

    }
    print $record;
}

