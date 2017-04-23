#!/usr/bin/perl

$|=1;
use strict;

if (scalar(@ARGV) != 4) {
    print "Usage: allele_diff.pl <normal_allele_call_file> <tumor_allele_call_file> <threshold> <output_prefix>\n\n";
    exit(-1);
}

print "STARTING allele_diff.pl @ARGV\n";

my ($first, $second, $threshold, $output_prefix) = @ARGV;

open(FIRST, $first) or die;
open(SECOND, $second) or die;

my $number_confident_calls_1 = 0;
my $number_confident_calls_2 = 0;
my $number_joint_confident_calls = 0;
my $number_diff_from_ref_1       = 0;
my $number_diff_from_ref_2       = 0;
my $number_diff_from_ref_joint   = 0;
my $number_agree                 = 0;
my $number_disagree              = 0;
my $number_normal                = 0;
my $number_somatic               = 0;

my @unique_to_normal_lines = ();
my @unique_to_tumor_lines  = ();

my @confident_in_first   = ();
my @confident_in_second  = ();

my @confident_in_first_not_second   = ();
my @confident_in_second_not_first  = ();

my @lod_vs_cov_lines = ();

my @het_balance_1 = ();
my @het_balance_2 = ();

my $number_of_effective_bases = 0;

while ((not(eof(FIRST))) and (not(eof(SECOND))))
{
    my $first_line  = <FIRST>;
    my $second_line = <SECOND>;

    $first_line  =~ s/(^\s+)|(\s+$)//g;
    $second_line =~ s/(^\s+)|(\s+$)//g;

    my @first_tokens  = split(/\s+/, $first_line); 
    my @second_tokens = split(/\s+/, $second_line); 

    my ($loci_1, $ref_1, $hyp_1, $btnb_1, $btr_1, $call_1, $a_1, $c_1, $g_1, $t_1, $cov_1, $prior, $bait_present, $alignable) = @first_tokens;
    my ($loci_2, $ref_2, $hyp_2, $btnb_2, $btr_2, $call_2, $a_2, $c_2, $g_2, $t_2, $cov_2, $prior, $bait_present, $alignable) = @second_tokens;

    $btr_1 = abs($btr_1);
    $btr_2 = abs($btr_2);

    if ($btr_1 == 0) { $btr_1 = $btnb_1; }
    if ($btr_2 == 0) { $btr_2 = $btnb_2; }

    if (not ($bait_present and $alignable)) { next; }
    $number_of_effective_bases += 1;

    my $lod_vs_cov_line = "$btr_1 $btr_2 $cov_1 $cov_2";
    push(@lod_vs_cov_lines, $lod_vs_cov_line);

    die "ERROR: OUT OF SYNC." if ($loci_1 ne $loci_2);

    if ($btr_1 >= $threshold) { push(@confident_in_first,  $first_line); }
    if ($btr_2 >= $threshold) { push(@confident_in_second, $second_line); }

    if (($btr_1 >= $threshold) and ($btr_2 <  $threshold)) { push(@confident_in_first_not_second, "NORMAL: $first_line\nTUMOR : $second_line\n"); }
    if (($btr_1 <  $threshold) and ($btr_2 >= $threshold)) { push(@confident_in_second_not_first, "NORMAL: $first_line\nTUMOR : $second_line\n"); }

    if (($btr_1 >= $threshold) and ($btr_2 >= $threshold))
    {
        $number_joint_confident_calls += 1;

        if ($hyp_1 ne "$ref_1$ref_1") { $number_diff_from_ref_1 += 1; }
        if ($hyp_2 ne "$ref_2$ref_2") { $number_diff_from_ref_2 += 1; }
        if (($hyp_1 ne "$ref_1$ref_1") && ($hyp_2 ne "$ref_2$ref_2")) { $number_diff_from_ref_joint += 1; }
    
        if ((($hyp_1 ne "$ref_1$ref_2") and ($hyp_2 eq "$ref_1$ref_2")) or
            (($hyp_1 eq "$ref_1$ref_2") and ($hyp_2 ne "$ref_1$ref_2")))
        {
            $number_disagree += 1;            
        } 
        else
        {
            $number_agree += 1;
        }

        if (($hyp_1 eq "$ref_1$ref_2") and ($hyp_2 ne "$ref_1$ref_2"))
        {
            $number_somatic += 1;
            push(@unique_to_tumor_lines, "NORMAL: $first_line\nTUMOR : $second_line\n");
        }

        if (($hyp_2 eq "$ref_1$ref_2") and ($hyp_1 ne "$ref_1$ref_2"))
        {
            $number_normal += 1;
            push(@unique_to_normal_lines, "NORMAL: $first_line\nTUMOR : $second_line\n");
        }
    }

    if ($call_1 eq "heterozygous-SNP")
    {
        my $count_line = "$a_1 $c_1 $g_1 $t_1";
        $count_line =~ s/[ACGT]\://g;
        my @counts = split(/\s+/, $count_line);
        #my ($a, $c, $g, $t) = split(/\s+/, $count_line);
        @counts = sort { $b <=> $a } @counts; 
        push(@het_balance_1, [$loci_1, $counts[0], $counts[1]]);
    }

    if ($call_2 eq "heterozygous-SNP")
    {
        my $count_line = "$a_2 $c_2 $g_2 $t_2";
        $count_line =~ s/[ACGT]\://g;
        my @counts = split(/\s+/, $count_line);
        #my ($a, $c, $g, $t) = split(/\s+/, $count_line);
        @counts = sort { $b <=> $a } @counts; 
        push(@het_balance_2, [$loci_2, $counts[0], $counts[1]]);
    }

}

my $number_of_confident_calls_in_normal = scalar(@confident_in_first);
my $number_of_confident_calls_in_tumor = scalar(@confident_in_second);

open(OUT, ">$output_prefix.stats") or die;
print OUT "number_of_effective_bases            $number_of_effective_bases\n";
print OUT "number_of_confident_calls_in_normal  $number_of_confident_calls_in_normal\n";
print OUT "number_of_confident_calls_in_tumor   $number_of_confident_calls_in_tumor\n";
print OUT "number_joint_confident_calls         $number_joint_confident_calls\n";
print OUT "number_SNP_calls_in_normal           $number_diff_from_ref_1\n";
print OUT "number_SNP_calls_in_tumor            $number_diff_from_ref_2\n";
print OUT "number_SNP_calls_in_both             $number_diff_from_ref_joint\n";
print OUT "number_calls_agree                   $number_agree\n";
print OUT "number_SNPs_disagree                 $number_disagree\n";
print OUT "number_SNPs_unique_to_normal         $number_normal\n";
print OUT "number_SNPs_unique_to_tumor          $number_somatic\n";
close(OUT);

open(OUT, ">$output_prefix.unique_to_normal") or die;
print OUT join("\n", @unique_to_normal_lines);
close(OUT);

open(OUT, ">$output_prefix.unique_to_tumor") or die;
print OUT join("\n", @unique_to_tumor_lines);
close(OUT);

open(OUT, ">$output_prefix.confident_in_normal") or die;
print OUT join("\n", @confident_in_first);
close(OUT);

open(OUT, ">$output_prefix.confident_in_tumor") or die;
print OUT join("\n", @confident_in_second);
close(OUT);

open(OUT, ">$output_prefix.confident_in_normal_but_not_tumor") or die;
print OUT join("\n", @confident_in_first_not_second);
close(OUT);

open(OUT, ">$output_prefix.confident_in_tumor_but_not_normal") or die;
print OUT join("\n", @confident_in_second_not_first);
close(OUT);

open(OUT, ">$output_prefix.lod_vs_cov") or die;
print OUT join("\n", @lod_vs_cov_lines);
close(OUT);

open(OUT, ">$output_prefix.het_balance_in_normal") or die;
for (my $i = 0; $i < scalar(@het_balance_1); $i++)
{
    my ($locus, $major, $minor) = @{$het_balance_1[$i]};
    print OUT "$locus $major $minor\n";
}
close(OUT);

open(OUT, ">$output_prefix.het_balance_in_tumor") or die;
for (my $i = 0; $i < scalar(@het_balance_2); $i++)
{
    my ($locus, $major, $minor) = @{$het_balance_2[$i]};
    print OUT "$locus $major $minor\n";
}
close(OUT);


my $command;

$command = "cat $first  | awk '{if  (\$5 == 0) { print -1*\$4; } else { print \$5; }}' > $output_prefix.first.BTR";
system($command);
if ($? != 0) { die("failed: $command"); }

$command = "cat $second | awk '{if  (\$5 == 0) { print -1*\$4; } else { print \$5; }}' > $output_prefix.second.BTR";
system($command);
if ($? != 0) { die("failed: $command"); }

$command = "cat $first | awk '{print \$11}' > $output_prefix.first.coverage";
system($command);
if ($? != 0) { die("failed: $command"); }

$command = "cat $second | awk '{print \$11}' > $output_prefix.second.coverage";
system($command);
if ($? != 0) { die("failed: $command"); }

$command = "echo \"first_BTR second_BTR first_coverage second_coverage\" > $output_prefix.BTR; paste $output_prefix.first.BTR $output_prefix.second.BTR $output_prefix.first.coverage $output_prefix.second.coverage >> $output_prefix.BTR";
system($command);
if ($? != 0) { die("failed: $command"); }

unlink("$output_prefix.first.BTR");
unlink("$output_prefix.second.BTR");
unlink("$output_prefix.first.coverage");
unlink("$output_prefix.second.coverage");

print "FINISHED allele_diff.pl @ARGV\n";


