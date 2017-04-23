use strict;
use warnings;

#
# Declare variables
#

#
# The PROSITE database
#
my $prosite_file = 'prosmall.dat';

#
# A "handle" for the opened PROSITE file
#
my $prosite_filehandle; 

#
# Store each PROSITE record that is read in
#
my $record = '';

#
# The protein sequence to search
# (use "join" and "qw" to keep line length short)
#
my $protein = join '', qw(
MNIDDKLEGLFLKCGGIDEMQSSRTMVVMGGVSG
QSTVSGELQDSVLQDRSMPHQEILAADEVLQESE
MRQQDMISHDELMVHEETVKNDEEQMETHERLPQ
);

#
# open the PROSITE database or exit the program
#
open($prosite_filehandle, $prosite_file)
 or die "Cannot open PROSITE file $prosite_file";

#
# set input separator to termination line //
#
$/ = "//\n";

#
# Loop through the PROSITE records
#
while($record = <$prosite_filehandle>) {

  #
  # Parse the PROSITE record into its "line types"
  #
  my %line_types = get_line_types($record);

  #
  # Skip records without an ID (the first record)
  #
  defined $line_types{'ID'} or next;

  #
  # Skip records that are not PATTERN
  # (such as MATRIX or RULE)
  #
  $line_types{'ID'} =~ /PATTERN/ or next;

  #
  # Get the ID of this record
  #
  my $id = $line_types{'ID'};
  $id =~ s/^ID   //;
  $id =~ s/; .*//;

  #
  # Get the PROSITE pattern from the PA line(s)
  #
  my $pattern = $line_types{'PA'};
  # Remove the PA line type tag(s)
  $pattern =~ s/PA   //g;

  #
  # Calculate the Perl regular expression
  # from the PROSITE pattern
  #
  my $regexp =  PROSITE_2_regexp($pattern);

  #
  # Find the PROSITE regular expression patterns
  # in the protein sequence, and report
  #
  while ($protein =~ /$regexp/g) {
    my $position = (pos $protein) - length($&) +1;
    print "Found $id at position $position\n";
    print "   match:   $&\n";
    print "   pattern: $pattern\n";
    print "   regexp:  $regexp\n\n";
  }
}

#
# Exit the program
#
exit;


##################################################
#
# Subroutines
#
##################################################
#
# Calculate a Perl regular expression
#  from a PROSITE pattern
#
sub PROSITE_2_regexp {

  #
  # Collect the PROSITE pattern
  #
  my($pattern) = @_;

  #
  # Copy the pattern to a regular expression
  #
  my $regexp = $pattern;

  #
  # Now start translating the pattern to an
  #  equivalent regular expression
  #

  #
  # Remove the period at the end of the pattern
  #
  $regexp =~ s/.$//;

  #
  # Replace 'x' with a dot '.'
  #
  $regexp =~ s/x/./g;

  #
  # Leave an ambiguity such as '[ALT]' as is.
  #   However, there are two patterns [G>] that need
  #   special treatment (and the PROSITE documentation
  #   is a bit vague, perhaps).
  #
  $regexp =~ s/\[G\>\]/(G|\$)/;
  
  #
  # Ambiguities such as {AM} translate to [^AM].
  #
  $regexp =~ s/{([A-Z]+)}/[^$1]/g;

  #
  # Remove the '-' between elements in a pattern
  #
  $regexp =~ s/-//g;

  #
  # Repetitions such as x(3) translate as x{3}
  #
  $regexp =~ s/\((\d+)\)/{$1}/g;

  #
  # Repetitions such as x(2,4) translate as x{2,4}
  #
  $regexp =~ s/\((\d+,\d+)\)/{$1}/g;

  #
  # '<' becomes '^' for "beginning of sequence"
  #
  $regexp =~ s/\</^/;

  #
  # '>' becomes '$' for "end of sequence"
  #
  $regexp =~ s/\>/\$/;

  #
  # Return the regular expression
  #
  return $regexp;
}



#
# Calculate a Perl regular expression
#  from a PROSITE pattern using a clever
#  and fast "shortcut".  This is not used
#  here, but could be called instead of
#  PROSITE_2_regexp
#
sub PROSITE_2_regexp_clever {

  my($pattern) = @_;

  $pattern =~ s/{/[^/g;
  $pattern =~ tr/cx}()<>\-\./C.]{}^$/d;
  $pattern =~ s/\[G\$\]/(G|\$)/;

  # Return PROSITE pattern translated to Perl regular expression
  return $pattern;
}



#
# Parse a PROSITE record into "line types" hash
# 
sub get_line_types {

  #
  # Collect the PROSITE record
  #
  my($record) = @_;

  #
  # Initialize the hash
  #   key   = line type
  #   value = lines
  #
  my %line_types_hash = ();

  #
  # Split the PROSITE record to an array of lines
  #
  my @records = split(/\n/,$record);

  #
  # Loop through the lines of the PROSITE record
  #
  foreach my $line (@records) {

    #
    # Extract the 2-character name
    # of the line type
    #
    my $line_type = substr($line,0,2);

    #
    # Append the line to the hash
    # indexed by this line type
    #
    (defined $line_types_hash{$line_type})
    ?  ($line_types_hash{$line_type} .= $line)
    :  ($line_types_hash{$line_type} = $line);
  }

  #
  # Return the hash 
  #
  return %line_types_hash;
}
