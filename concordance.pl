#!/usr/bin/perl

$|=1;
use strict;

my ($truth_file, $individual, $allele_file, $threshold_start, $threshold_step, $threshold_end, $output, $errors, $correct) = @ARGV;

if (not defined($errors)) { $errors = "/dev/null"; }
if (not defined($correct)) { $correct = "/dev/null"; }


my $temp_truth_file  = "$output.temp_truth";
my $temp_allele_file = "$output.temp_alleles";
my $temp_joined_file = "$output.temp_joined";

open(TRUTH, $truth_file) or die;
my $header = <TRUTH>;
my @header = split(/\s+/, $header);

my $reference_column = undef;

for (my $i = 0; $i < scalar(@header); $i++)
{
    if ($header[$i] eq $individual) { $reference_column = $i; last; }
}

die if (not defined($reference_column)) ;

my $command;

# have to flip alleles
$command = "cat $truth_file | awk '{print \$3\":\"\$4-1,\$5,\$($reference_column+1)}' | perl -pe 's/chrX/23/; s/chrY/24/; s/chrM/0/; s/chr//;' | perl -ane 'if (\$F[1] eq \"+\") { print \"\$F[0] \$F[2]\\n\"; } else { \$F[2] =~ tr/ACGTacgt/TGCAtgca/; \$F[2] = reverse \$F[2]; print \"\$F[0] \$F[2]\\n\"; }' |  grep -v NN | sort -k 1 > $temp_truth_file";
#print "\n$command\n";
system($command);
if ($? != 0) { die("failed: $command"); }

$command = "cat $allele_file |  sort -k 1 > $temp_allele_file";
#print "\n$command\n";
system($command);
if ($? != 0) { die("failed: $command"); }

$command = "join -j 1 $temp_truth_file $temp_allele_file > $temp_joined_file";
#print "\n$command\n";
system($command);
if ($? != 0) { die("failed: $command"); }

open(OUT, ">$output") or die;

print OUT "HapMap Concordance of individual $individual\n";
print OUT "THRESHOLD TOTAL_SITES TOTAL_CONFIDENT_CALLS CORRECT INCORRECT CONCORDANCE ALLELE_BALANCE_MEAN ALLELE_BALANCE_STDEV HET_SITE_CONFIDENT_CALLS HET_CORRECT HET_INCORRECT HET_CONCORDANCE\n";
for (my $threshold = $threshold_start; $threshold <= $threshold_end; $threshold += $threshold_step)
{
	my $right = `cat $temp_joined_file | awk '{if ((\$5 >= $threshold) && (\$2 == \$4)) { print; }}' | wc -l`; $right =~ s/(^\s+)|(\s+$)//g;
	my $wrong = `cat $temp_joined_file | awk '{if ((\$5 >= $threshold) && (\$2 != \$4)) { print; }}' | wc -l`; $wrong =~ s/(^\s+)|(\s+$)//g;
 	my $total = `cat $temp_joined_file | awk '{if ((\$5 >= $threshold)) { print; }}' | wc -l`; $total =~ s/(^\s+)|(\s+$)//g;
 	my $total_hapmap_sites = `cat $temp_joined_file | wc -l`; $total_hapmap_sites =~ s/(^\s+)|(\s+$)//g;

        $command = "cat $temp_joined_file | awk '{if ((\$5 >= $threshold) && (\$2 == \$4)) { print; }}' > $correct.threshold_$threshold";
        system($command);
        if ($? != 0) { die("failed: $command"); }
 
	$command = "cat $temp_joined_file | awk '{if ((\$5 >= $threshold) && (\$2 != \$4)) { print; }}' > $errors.threshold_$threshold";
        system($command);
        if ($? != 0) { die("failed: $command"); }


        my $concordance = sprintf("%0.02f", 100.0 * $right / $total);

        my ($allele_balance_mean, $allele_balance_stdev, $allele_balance_distribution) = compute_allele_balance($temp_joined_file, $threshold);


        my $het_right = `cat $temp_joined_file | awk '{if ((\$5 >= $threshold) && (substr(\$2,1,1) != substr(\$2,2,1)) && (\$2 == \$4)) { print; }}' | wc -l`; $right =~ s/(^\s+)|(\s+$)//g;
        my $het_wrong = `cat $temp_joined_file | awk '{if ((\$5 >= $threshold) && (substr(\$2,1,1) != substr(\$2,2,1)) && (\$2 != \$4)) { print; }}' | wc -l`; $wrong =~ s/(^\s+)|(\s+$)//g;
        my $het_total = `cat $temp_joined_file | awk '{if ((\$5 >= $threshold) && (substr(\$2,1,1) != substr(\$2,2,1))) { print; }}' | wc -l`; $total =~ s/(^\s+)|(\s+$)//g;

 	my $het_concordance = sprintf("%0.02f", 100.0 * $het_right / $het_total);
 
 	
	print OUT sprintf("%0.01f %10d %10d %10d %10d %0.03f %0.03f %0.03f %10d %10d %10d %0.03f\n", $threshold, $total_hapmap_sites, $total, $right, $wrong, $concordance, $allele_balance_mean, $allele_balance_stdev, $het_total, $het_right, $het_wrong, $het_concordance);
}

close(OUT);

unlink $temp_truth_file, $temp_allele_file, $temp_joined_file;

sub compute_allele_balance
{
    my ($input, $threshold) = @_;

    my @het_dist = ();
    my $sum = 0;
    my $count = 0;

    for  (my $i = 0; $i < 10; $i++) { $het_dist[$i] = 0; }

    open(IN, $input) or die;
    while(<IN>)
    {
        my ($loc, $hapmap, $ref, $hyp, $btnb, $btr) = split(/\s+/, $_);

        if ($btr < $threshold) { next; }
        
        my ($h1, $h2) = split("", $hapmap);  

        if ($h1 eq $h2) { next; }

        $_ =~ m/$h1\:(\d+)/ or die;
        my $c1 = $1;

        $_ =~ m/$h2\:(\d+)/ or die;
        my $c2 = $1;

        if ($c1 == 0) { $c1 = 0.0000001; }
        if ($c2 == 0) { $c2 = 0.0000001; }

        my $balance;
        if ($h1 eq $ref)    { $balance = $c2 / ($c1+$c2);    }
        elsif ($h2 eq $ref) { $balance = $c1 / ($c1+$c2);    }
        else                { die "WARNING: het, both nonref :\n$_\n";}

        $sum += $balance;    
        $count += 1;

        $het_dist[int($balance * 10)] += 1;
    }
    close(IN);

    my $mean = $sum / $count;

    $sum = 0;

    open(IN, $input) or die;
    while(<IN>)
    {
        my ($loc, $hapmap, $ref, $hyp, $btnb, $btr) = split(/\s+/, $_);

        if ($btr < $threshold) { next; }
        
        my ($h1, $h2) = split("", $hapmap);  

        if ($h1 eq $h2) { next; }

        $_ =~ m/$h1\:(\d+)/ or die;
        my $c1 = $1;

        $_ =~ m/$h2\:(\d+)/ or die;
        my $c2 = $1;

        my $balance;
        if ($h1 eq $ref)    { $balance = $c2 / ($c1+$c2);    }
        elsif ($h2 eq $ref) { $balance = $c1 / ($c1+$c2);    }
        else                { die "WARNING: het, both nonref :\n$_\n"; }

        $sum += ($balance - $mean)**2;
    }
    close(IN);

    my $stdev = ($sum / $count);

    my $het_dist = join(",", @het_dist);

    return ($mean, $stdev, $het_dist);
}





