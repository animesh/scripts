#! /usr/bin/perl

if ($#ARGV != 1 && $#ARGV != 2 && $#ARGV != 3 )
{
    print "Useage: $0  ref_size lengths_file  inserts_file  [ output_file ]\n";
    print "  Computes the estimates of the new genome size based on\n";
    print "  comparing the original lengths in  lengths_file  and the\n";
    print "  observed lengths in  inserts_file.\n";
    print "  If the optional  output_file  is given, the original and\n";
    print "  observed lengths are saved there.\n";
    exit(0);
}

$reference_size = $ARGV[0];
$lengths_file = $ARGV[1];
$inserts_file = $ARGV[2];

$output_file = "";
if ($#ARGV == 3)
{
    $output_file = $ARGV[3];
}

# Sante - replaced $human_size with the argument $reference_size.
# $human_size = 2850000000;
# $default_orig_length_mean = 39918;
# $default_orig_length_stddev = 1936;


####################
# Load array of original lengths

$now_time = localtime;
print "$now_time: Reading $lengths_file...\n";

open(LENGTHS_FILE, $lengths_file) ||
    die "Can't open $lengths_file\n";

%lengths = ();
$index = 0;

while (<LENGTHS_FILE>)
{
    chomp;
    $read_id = sprintf "%06d", $index;
    $lengths{$read_id} = $_;

    $index++;
}

close(LENGTHS_FILE);

$now_time = localtime;
print "$now_time: Reading $lengths_file...done.\n";

$num_lengths = $index;

####################
# Load array synteny lengths and compute
# the ratios of these to the original lengths

$now_time = localtime;
print "$now_time: Reading $inserts_file...\n";

open(INSERTS_FILE, $inserts_file) ||
    die "Can't open $inserts_file\n";

$num_inserts = 0;

@read_ids = ();
@ratios = ();
@synteny_lengths = ();
@orig_lengths = ();

while (<INSERTS_FILE>)
{
    /^\s*(\d+)\s+(\-?\d+)\s*/;

    $read_id = sprintf "%06d", $1;
    $orig_length = $lengths{$read_id};
    $synteny_length = $2;

    $ratio = $orig_length / $synteny_length;

    $num_inserts++;

    push @read_ids, $read_id;
    push @ratios, $ratio;
    push @synteny_lengths, $synteny_length;
    push @orig_lengths, $orig_length;
}

$now_time = localtime;
print "$now_time: Reading $inserts_file...done.\n";

close (INSERTS_FILE);

####################
# Compute the range of ratio-values for which
# we want to accept the inserts

$now_time = localtime;
print "$now_time: Filtering...\n";

@sorted_ratios = sort @ratios;

$m25 = $sorted_ratios[$num_inserts / 4];
$m50 = $sorted_ratios[$num_inserts / 2];
$m75 = $sorted_ratios[3 * $num_inserts / 4];

$lower_bound = $m50 - 2 * ($m50 - $m25);
$upper_bound = $m50 + 2 * ($m75 - $m50);

  # print "Insert ratio lower  quartile (m25)         = $m25\n";
  # print "Insert ratio middle quartile (m50, median) = $m50\n";
  # print "Insert ratio upper  quartile (m75)         = $m75\n";
  # 
  # print "Insert ratio lower bound = $lower_bound\n";
  # print "Insert ratio upper bound = $upper_bound\n";


####################
# Filter the inserts, output the accepted ones to the output file,
# and compute the sum and sum-of-squares of original and synteny lengths
# for later use.

if ($output_file ne "")
{
    $now_time = localtime;
    print "$now_time: Writing to $output_file...\n";

    open(OUTPUT_FILE, "> $output_file") ||
	die "Can't open $ratios_file for output\n";
}

$num_inserts_used = 0;

$sum_synteny_lengths = 0;
$sum_sq_synteny_lengths = 0;

$sum_orig_lengths = 0;
$sum_sq_orig_lengths = 0;

for ($i = 0; $i < $num_inserts; $i++)
{
    $ratio = $ratios[$i];

    if ($ratio >= $lower_bound &&
	$ratio <= $upper_bound)
    {
	$num_inserts_used++;

	$read_id = $read_ids[$i];
	$orig_length = $orig_lengths[$i];
	$synteny_length = $synteny_lengths[$i];

	$sum_synteny_lengths += $synteny_length;
	$sum_sq_synteny_lengths += $synteny_length * $synteny_length;

	$sum_orig_lengths += $orig_length;
	$sum_sq_orig_lengths += $orig_length * $orig_length;

	$outline = sprintf "%s %5d %5d %2.3f\n",
	($read_id, $orig_length, $synteny_length, $ratio);

	if ($output_file ne "")
	{
	    print OUTPUT_FILE $outline;
	}
    }
}

if ($output_file ne "")
{
    close (OUTPUT_FILE);

    $now_time = localtime;
    print "$now_time: Writing to $output_file...done.\n";
}


$now_time = localtime;
print "$now_time: Filtering...done.\n";

if ($num_inserts_used == 0)
{
    die "ERROR: No acceptable inserts found.\n";
}

####################
# Compute the genome size estimates.

$synteny_length_mean = $sum_synteny_lengths / $num_inserts_used;
$synteny_length_stddev = sqrt($sum_sq_synteny_lengths / $num_inserts_used
			      - $synteny_length_mean * $synteny_length_mean );

$orig_length_mean = $sum_orig_lengths / $num_inserts_used;
$orig_length_stddev = sqrt($sum_sq_orig_lengths / $num_inserts_used
			   - $orig_length_mean * $orig_length_mean );
print "\n\n";
print "----------------------------------------\n";
print "Using observed values of MOL:\n\n";

printf "Number of given inserts        = %6u\n", $num_lengths;
printf "Number of aligned  inserts     = %6u  (%2.1f\%)\n",
    ($num_inserts, 100 * $num_inserts / $num_lengths);
printf "Number of inserts used (N)     = %6u  (%2.1f\%)\n",
    ($num_inserts_used, 100 * $num_inserts_used / $num_lengths);
printf "Mean   syntey length   (MSL)   = %6u\n", $synteny_length_mean;
printf "Stddev syntey length   (MSLsd) = %6u\n", $synteny_length_stddev;
printf "Mean   original length (MOL)   = %6u\n", $orig_length_mean;
printf "Stddev original length (MOLsd) = %6u\n", $orig_length_stddev;

$est_size = $reference_size * $sum_orig_lengths / $sum_synteny_lengths;

$est_size_1sd_lower = 
    $reference_size
    * ($orig_length_mean - $orig_length_stddev / sqrt($num_inserts_used) )
    / ($synteny_length_mean + $synteny_length_stddev / sqrt($num_inserts_used) );

$est_size_2sd_lower = 
    $reference_size
    * ($orig_length_mean - 2 * $orig_length_stddev / sqrt($num_inserts_used) )
    / ($synteny_length_mean + 2 * $synteny_length_stddev / sqrt($num_inserts_used) );

$est_size_1sd_upper = 
    $reference_size
    * ($orig_length_mean + $orig_length_stddev / sqrt($num_inserts_used) )
    / ($synteny_length_mean - $synteny_length_stddev / sqrt($num_inserts_used) );

$est_size_2sd_upper = 
    $reference_size
    * ($orig_length_mean + 2 * $orig_length_stddev / sqrt($num_inserts_used) )
    / ($synteny_length_mean - 2 * $synteny_length_stddev / sqrt($num_inserts_used) );

print "\n";

$one_billion = 1000000000;

printf "The estimated genome size is         %5.3f Gbp\n",
    $est_size/$one_billion;
printf "The 1sd window estimate   is [ %5.3f Gbp, %5.3f Gbp]\n",
    ($est_size_1sd_lower/$one_billion, $est_size_1sd_upper/$one_billion);
printf "The 2sd window estimate   is [ %5.3f Gbp, %5.3f Gbp]\n",
    ($est_size_2sd_lower/$one_billion, $est_size_2sd_upper/$one_billion);


print "----------------------------------------\n";

# print "Using default values of MOL:\n\n";
# 
# printf "Number of original inserts     = %6u\n", $num_lengths;
# printf "Number of aligned  inserts     = %6u  (%2.1f\%)\n",
#     ($num_inserts, 100 * $num_inserts / $num_lengths);
# printf "Number of inserts used (N)     = %6u  (%2.1f\%)\n",
#     ($num_inserts_used, 100 * $num_inserts_used / $num_lengths);
# printf "Mean   syntey length   (MSL)   = %6u\n", $synteny_length_mean;
# printf "Stddev syntey length   (MSLsd) = %6u\n", $synteny_length_stddev;
# printf "Mean   original length (MOL)   = %6u  (default)\n", $default_orig_length_mean;
# printf "Stddev original length (MOLsd) = %6u  (default)\n", $default_orig_length_stddev;
# 
# $est_size = $reference_size * $default_orig_length_mean / $synteny_length_mean;
# 
# $est_size_1sd_lower = 
#     $reference_size
#     * ($default_orig_length_mean - $default_orig_length_stddev / sqrt($num_inserts_used) )
#     / ($synteny_length_mean + $synteny_length_stddev / sqrt($num_inserts_used) );
# 
# $est_size_2sd_lower = 
#     $reference_size
#     * ($default_orig_length_mean - 2 * $default_orig_length_stddev / sqrt($num_inserts_used) )
#     / ($synteny_length_mean + 2 * $synteny_length_stddev / sqrt($num_inserts_used) );
# 
# $est_size_1sd_upper = 
#     $reference_size
#     * ($default_orig_length_mean + $default_orig_length_stddev / sqrt($num_inserts_used) )
#     / ($synteny_length_mean - $synteny_length_stddev / sqrt($num_inserts_used) );
# 
# $est_size_2sd_upper = 
#     $reference_size
#     * ($default_orig_length_mean + 2 * $default_orig_length_stddev / sqrt($num_inserts_used) )
#     / ($synteny_length_mean - 2 * $synteny_length_stddev / sqrt($num_inserts_used) );
# 
# print "\n";
# printf "The estimated genome size is         %10u\n",
#     $est_size;
# printf "The 1sd window estimate   is [ %10u , %10u ]\n",
#     ($est_size_1sd_lower, $est_size_1sd_upper);
# printf "The 2sd window estimate   is [ %10u , %10u ]\n",
#     ($est_size_2sd_lower, $est_size_2sd_upper);
# print "----------------------------------------\n";

