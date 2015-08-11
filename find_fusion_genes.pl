#!/usr/bin/perl

$|=1;
use strict;

my ($reads_a, $aligns_a, $reads_b, $aligns_b, $output_head) = @ARGV;

my $base_head = `basename $reads_a .fastb`; $base_head =~ s/\s+$//g;
$output_head = $output_head . "/$base_head/$base_head";

system("mkdir -p `dirname $output_head`");

my $command_1 = "FusionGeneFinder \\\
    REF=/seq/references/Homo_sapiens_assembly18/v0/Homo_sapiens_assembly18.fasta.lookuptable.fastb \\\
    READS_A=$reads_a \\\
    READS_B=$reads_b \\\
    ENSEMBL=/wga/scr2/jmaguire/cDNA/Ensembl/curated.48/Ensembl48_Curated_Genes.list \\\
    ALIGNS_A=$aligns_a \\\
    ALIGNS_B=$aligns_b \\\
    SKIP_SELF_LINKS=True \\\
    MIN_LINK_COUNTS=2 \\\
    MIN_DISTANCE=1000000 \\\
    MAX_ERRS=1 \\\
    OUTPUT=$output_head.putative_links \\\
    PUTATIVE_FUSION_READS_OUTPUT_PREFIX=$output_head.interesting_reads;";

my $command_2 = "QueryLookupTable \\\
    K=12 MM=12 MC=0.15 \\\
    SEQS=$output_head.interesting_reads_a.fusion.fastb \\\
    L=/seq/references/Homo_sapiens_assembly18/v0/Homo_sapiens_assembly18.fasta.lookuptable.lookup \\\
    MF=5000 \\\
    FILTER=False \\\
    QUIET=True \\\
    MAX_ERROR_PERCENT=10 \\\
    PARSEABLE=True \\\
    OUTFILE=$output_head.interesting_reads_a.fusion.qltout &  \\\
QueryLookupTable \\\
    K=12 MM=12 MC=0.15 \\\
    SEQS=$output_head.interesting_reads_b.fusion.fastb \\\
    L=/seq/references/Homo_sapiens_assembly18/v0/Homo_sapiens_assembly18.fasta.lookuptable.lookup \\\
    MF=5000 \\\
    FILTER=False \\\
    QUIET=True \\\
    MAX_ERROR_PERCENT=10 \\\
    PARSEABLE=True \\\
    OUTFILE=$output_head.interesting_reads_b.fusion.qltout & \\\
wait;";


my $command_3 = "FusionGeneFinder \\\
    REF=/seq/references/Homo_sapiens_assembly18/v0/Homo_sapiens_assembly18.fasta.lookuptable.fastb \\\
    READS_A=$output_head.interesting_reads_a.fusion.fastb \\\
    READS_B=$output_head.interesting_reads_b.fusion.fastb \\\
    ENSEMBL=/wga/scr2/jmaguire/cDNA/Ensembl/curated.48/Ensembl48_Curated_Genes.list \\\
    ALIGNS_A=$output_head.interesting_reads_a.fusion.qltout \\\
    ALIGNS_B=$output_head.interesting_reads_b.fusion.qltout \\\
    SKIP_SELF_LINKS=True \\\
    MIN_LINK_COUNTS=2 \\\
    MIN_DISTANCE=1000000 \\\
    MAX_ERRS=1 \\\
    OUTPUT=$output_head.final_links \\\
    OUTPUT_SEPERATE_PILES=True \\\
    PUTATIVE_FUSION_READS_OUTPUT_PREFIX=$output_head.final_reads;";

system($command_1) == 0 or die "died on command:\n $command_1"; 
system($command_2) == 0 or die "died on command:\n $command_2"; 
system($command_3) == 0 or die "died on command:\n $command_3"; 

