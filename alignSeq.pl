#!/usr/bin/perl

#alignSeq.pl

use strict;
use lib "/home/willkn/biochem/sw/bioperl/lib/site_perl/5.6.1";
use Bio::SeqIO;
use Bio::SeqIO::MultiFile;
use Bio::SeqIO::fasta;
use Bio::AlignIO;
use Bio::Tools::pSW;

my $f_sScript = "alignSeq.pl";
my $f_sDescrip = "Prints an alignment between 2 nucleic-acid sequences";

#----------------------------------------------------------------------------
# main
#----------------------------------------------------------------------------

	# params
	if( @ARGV < 2 )
	{
		print( "usage: $f_sScript <seqFile1> <seqFile2>\n" );
		exit( 0 );
	}

	my $sSeqFile1 = shift;
	my $sSeqFile2 = shift;

	# read seqs from file
	my $seq_in = Bio::SeqIO::MultiFile->new( 
		-format => 'Fasta',
		-files => [$sSeqFile1, $sSeqFile2] );

	my $seq1 = $seq_in->next_seq();
	my $seq2 = $seq_in->next_seq();
	my $sSeq1 = $seq1->seq();
	my $sSeq2 = $seq2->seq(); 
	$sSeq1 =~ s/[0-9]//g;
	$sSeq2 =~ s/[0-9]//g;
#	print( "first sequence = $sSeq1\n" );

	my $alignout = new Bio::AlignIO();
	my $sBioPath = "/home/willkn/install/bioperl/bioperl-1.2.3/scripts/tools";
	my $sBlaFile = "$sBioPath/blosum62.bla";
	my $factory = new Bio::Tools::pSW( -matrix => $sBlaFile ); 
	my $aln = $factory->pairwise_alignment( $seq1, $seq2 );
	my @seqs = $aln->each_seq();

