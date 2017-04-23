#!/usr/local/bin/perl
# Numerical Recipes diff program
# This is a PERL script. If you don't have PERL, it can be acquired via
# anonymous-ftp from jpl-devvax.jpl.nasa.gov.
# This program compares output from Numerical Recipes results, in terms of
# acceptable tolerances and relative errors.
# It is intended as an aid in screening the output.
# Note this is an UNSUPPORTED product, provided for your convenience.

# Tolerance parameters
$NEAR_ZERO = 1e-05; # How small a number should be considered essentially zero
$REL_ERR = 1e-03; # Acceptable relative error (relative to first number)

if ($#ARGV != 1) {
  die "Syntax: $0 : [file1 | directory1 ] [ file2 | directory2 ]\n";
}

undef($/);
# Slurp files whole from <>

if (-f $ARGV[0] && -f $ARGV[1]) {
  &fuzzy_compare($ARGV[0], $ARGV[1]);
}
elsif (-d $ARGV[0] && -d $ARGV[1]) {
  $dir1 = $ARGV[0];
  $dir2 = $ARGV[1];
  opendir(DIR1, $dir1) || die "Can't open dir $dir1";
  opendir(DIR2, $dir2) || die "Can't open dir $dir2";
  @dir1_contents = readdir(DIR1);
  foreach (@dir1_contents) {
    next if (/^\./);
    if (-e "$dir2/$_") {
      &fuzzy_compare("$dir1/$_", "$dir2/$_");
    }
    else {
      warn("$dir2/$_ - missing\n");
    }
  }
}
elsif (-f $ARGV[0] && -d $ARGV[1]) {
  $ARGV[0] =~ m,([^/]+)$,;
  # take last component of path
  &fuzzy_compare($ARGV[0], "$ARGV[1]/$&");
}
elsif (-d $ARGV[0] && -f $ARGV[1]) {
  $ARGV[1] =~ m,([^/]+)$,;
  &fuzzy_compare("$ARGV[0]/$&", $ARGV[1]);
}
else {
  warn("Must be files or directories: $ARGV[0], $ARGV[1]\n");
}

sub fuzzy_compare {
  local($file1) = $_[0];
  local($file2) = $_[1];
  local(*FILE1, *FILE2);
  local(@file1_elements, @file2_elements, $file1_element_i, $file2_element_i);
  local($i, $tmp1, $tmp2, $diff);

  open(FILE1,"< $file1") || die "Can't open file $file1";
  open(FILE2,"< $file2") || die "Can't open file $file2";

  @file1_elements = split(/[][ \t\n(),=]+/,<FILE1>);
  @file2_elements = split(/[][ \t\n(),=]+/,<FILE2>);

  close(FILE1) || die "Can't close file $file1";
  close(FILE2) || die "Can't close file $file2";

  shift(@file1_elements)
    while (($file1_elements[0] eq '') && ($#file1_elements > 0));
  shift(@file2_elements)
    while (($file2_elements[0] eq '') && ($#file2_elements > 0));
  # Get rid of any initial null fields
  
  if ($#file1_elements != $#file2_elements) {
    print STDOUT
    "$file1 $file2 - can't compare - mismatch in number of elements\n";
    return;
  }

  for ($i = 0; $i <= $#file1_elements; $i++) {
  # Compare each element
    $file1_element_i = $file1_elements[$i];
    $file2_element_i = $file2_elements[$i];
    if (!(
      $file1_element_i =~ /^[-+.dDeE0-9]+$/ && $file1_element_i =~ /[0-9]/ &&
      $file2_element_i =~ /^[-+.dDeE0-9]+$/ && $file2_element_i =~ /[0-9]/)) {
      # Not numbers, but strings
      # Note that hex values fall into this case if they start with 0x
      ($tmp1 = $file1_element_i) =~ tr/A-Z/a-z/;
      ($tmp2 = $file2_element_i) =~ tr/A-Z/a-z/;
      # lowercase
      if ($tmp1 ne $tmp2) {
        print STDOUT
        "STRING DIFFERENCE: $file1 = $file1_element_i  $file2 = $file2_element_i\n";
      }
    }
    else {
    # they're both numbers
      next if ($file1_element_i == 0 && $file2_element_i == 0);
      next if (&abs($file1_element_i) < $NEAR_ZERO && &abs($file2_element_i) < $NEAR_ZERO);
      # they're both "small"
      if (($file1_element_i == 0 && $file2_element_i != 0) || ($file1_element_i != 0 && $file2_element_i == 0)) {
        print STDOUT
        "error for zero: $file1 = $file1_element_i  $file2 = $file2_element_i\n";
        next;
      }
      else {
        $diff = ($file2_element_i - $file1_element_i)/$file1_element_i;
        # relative error, based on first element
        if (&abs($diff) > $REL_ERR) {
          printf STDOUT 
          "DIFFERENCE: $file1 = $file1_element_i  $file2 = $file2_element_i  Relative Error = %.4g\n", $diff;
        }
      }
    }
  }
}

sub abs { return ( $_[0] >= 0 ? $_[0] : -$_[0] ); }
# Absolute value
