#!/usr/bin/perl
# corseqcol1.pl     krishn_bhakt@Bhakti-Yoga     2007/08/19 08:47:06

use warnings;
use strict;
$|=1;
use Data::Dumper;
use lib '/scratch/bioperl/';
use Bio::AlignIO;

my $fin=shift @ARGV;
my $fout=$fin.".aln2csv.txt";
my $str = Bio::AlignIO->new(-file=> $fin);
my $aln = $str->next_aln();
my $seq;
my %seqn;
my %seqs;
my @seqm;
my $cont=0;
my $c2;
open(FO,">$fout");


my %h2a = (
    '-' => 0,
	'I'		 => 		4.5,
	'V'		 => 		4.2,
	'L'		 => 		3.8,
	'F'		 => 		2.8,
	'C'		 => 		2.5,
	'M'		 => 		1.9,
	'A'		 => 		1.8,
	'G'		 => 		-0.4,
	'T'		 => 		-0.7,
	'W'		 => 		-0.9,
	'S'		 => 		-0.8,
	'Y'		 => 		-1.3,
	'P'		 => 		-1.6,
	'H'		 => 		-3.2,
	'E'		 => 		-3.5,
	'Q'		 => 		-3.5,
	'D'		 => 		-3.5,
	'N'		 => 		-3.5,
	'K'		 => 		-3.9,
	'R'		 => 		-4.5,
	'B'		 => 		-3.5,
	'Z'		 => 		-3.5,
	'X'		 => 		0,
	'*'		 => 		-4.5,
);

foreach $seq ( $aln->each_seq() ) {

    $seqs{$cont}=$seq->seq();
    $seqn{$cont}=$seq->display_id();
    my @t=split(//,$seqs{$cont});
    for($c2=0;$c2<=$#t;$c2++){
		$seqm[$cont][$c2]=$t[$c2];
		print FO"$t[$c2],";
    }
	print FO"\n";
    $cont++;
    print $seq->display_id(),"\n";
}



=head1 NAME

analyotp1.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for analyotp1.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

, E<lt>krishn_bhakt@Bhakti-YogaE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by 

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
