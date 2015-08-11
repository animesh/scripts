#!/usr/local/bin/perl

my $idmap = $ARGV[1];
my $ctg = $ARGV[0];

if ($#ARGV < 0 || $#ARGV > 2){
    print STDERR "Usage: ctg2umdcontig.pl file.ctg file.idmap [tigr] > file.uct\n";
    print STDERR "tigr - assumes .ctg file has 1-based coordinates\n";
    exit(1);
}

my %name2id;

my $tigr;
if (defined $ARGV[2]){
    $tigr = 1;
} else {
    if ($ARGV[1] eq "tigr"){
	$tigr = 1;
	$idmap = undef;
    }
}

if (defined $idmap){
    open(ID, $idmap) || die ("cannot open $idmap: $!\n");
    while (<ID>){
	chomp;
	my ($id, $name) = split(' ', $_);
	
	$name2id{$name} = $id;
    }
    close(ID);
}



my $ctgid = 0;
my $first = 1;
my %reads;
open(CTG, $ctg) || die ("Cannot open $ctg: $!\n");
while (<CTG>){
    if (/^\#\#(\d+) /){
	if (! $first){
	    foreach my $left (sort {$a <=> $b} (keys %reads)){
		print $reads{$left};
	    }
	    %reads = ();
	    print "\n";
	}
	$first = 0;
	print "C $1\n";
	next;
    }
    if (/^\#\#(\S+) /){ # not a number
	if (! $first){
	    foreach my $left (sort {$a <=> $b} (keys %reads)){
		print $reads{$left};
	    }
	    %reads = ();
	    print "\n";
	}
	$first = 0;
	print "C $ctgid\n";
	$ctgid++;
	next;
    }
    if (/^\#(\S+)\(.*{(\d+) (\d+)} <(\d+) (\d+)>/){
	my $name = $1;
	my $left = $4;
	my $right = $5;
	my $seql = $2;
	my $seqr = $3;
	
	my $id;
	if (exists $name2id{$name}){
	    $id = $name2id{$name};
	} elsif ($name =~ /^(\d+)$/){
	    $id = $1;
	} else {
	    die ("Cannot figure out id for read $name\n");
	}

	if (defined $tigr){
	    $left--;
	}
	my $asml; my $asmr;
	if ($seql < $seqr){
	    $asml = $left;
	    $asmr = $right;
	} else {
	    $asml = $right;
	    $asmr = $left;
	}
#	print " name is $name\n";
	while (exists $reads{$left}){
	    $left += 0.0001;
	}
	$reads{$left} = "$id $asml $asmr\n";
#	print "$name2id{$name} $asml $asmr\n";
    }
}
foreach my $left (sort {$a <=> $b} (keys %reads)){
    print $reads{$left};
}
