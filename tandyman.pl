#!/usr/local/bin/perl

# Note to downloader: This script should work on any system running perl 5 although it has not been tested on anything except Linux and Unix.  In order to run it, all you should have to do is change the first line above from #!/usr/local/bin/perl to #!/path/to/your/perl/executable  You may also have to install the perl module 'Getopt::Long' if you don't already have it.

#
#  @Name:        tandyman.pl
#  @Usage:       tandyman.pl -i sequence_file
#                  REQUIRED:
#                    -i <fasta sequence file>
#	           OPTIONAL:
#                    -c <coordinates file>
#                    -u <repeat unit size upper limit> (default: 1/2 sequence)
#                    -l <repeat unit size lower limit> (default: 2)
#                    -m <minimum number of units in a repeat>
#                    -e turns off sequence error checking
#                    -p <permissible characters to check sequence with (default: ATCGBDHVRYKMSWN), case insensitive>
#                         WARNING: Reverse complimenting will not happen if you use this option
#                    -r reports unit coordinates instead of repeat coordinates
#                    -g no reverse complimenting within backwards coordinates
#                    -s reports status of progress through standard error output by current unit size for which it is searching
#  @Purpose:     Finds tandem repeats in genomes submitted via file
#  @Takes:       fasta sequence file, tab delimited coordinate file with 
#                (ie. gene) start and stop coordinates followed by a comment, 
#                sequence type, and repeat unit size upper and lower limits
#  @Returns:     Prints tab delimited file of repeat coordinates.
#
#  @Author:      Robert Leach
#  @Company:     LANL
#  @Date:        8/17/2000,8/25/2000,9/29/2000 - unit coords option added
#

my $DEBUG = 0;

use Getopt::Long;

my ($seq_file,
    $coord_file,
    $umax,
    $umin,
    $minunits,
    $defchars,
    $defpchars,
    $chars,
    $rc_chars,
    $checkoff,
    $rc,
    $report_coords,
    $norevcomp,
    $status);

GetOptions('i=s' => \$seq_file,
           'c=s' => \$coord_file,
           'u=s' => \$umax,
           'l=s' => \$umin,
	   'm=s' => \$minunits,
	   'e!'  => \$checkoff,
           'r!'  => \$report_coords,
           'g!'  => \$norevcomp,
           'p=s' => \$chars,
	   's!'  => \$status);

#Set defaults...
$defchars  = 'ATCGBDHVRYKMSWN';                #Nucleotides and all possible cominations
$rc_chars  = 'TAGCVHDBYRMKSWN';
$defpchars = 'ARNDECQGHILKMFPSTWYVZ';          #Amino Acids
$chars     = $defchars unless($chars);
$chars     = uc($chars);
$rc_chars  = $chars if($chars ne $defchars);   #Reverse complimenting wont happen if $chars is supplied by user!
$default_comment           = 'CDS';            #Assume coordinates are coding region tandem repeats
$default_alternate_comment = 'IGR';            #Assume everything else is intergenic space

#Check for proper input...
unless($seq_file)
{
    print<<'end';
    
    Name:        tandyman.pl

    Usage:       tandyman.pl -i sequence_file
                   REQUIRED:
                     -i <fasta sequence file>
 	           OPTIONAL:
                     -c <coordinates file>
                     -u <repeat unit size upper limit> (default: 1/2 sequence)
                     -l <repeat unit size lower limit> (default: 2)
                     -m <minimum number of units in a repeat>
                     -e turns off sequence error checking
                     -p <permissible characters to check sequence with (default: ATCGBDHVRYKMSWN), case insensitive>
                          WARNING: Reverse complimenting will not happen if you use this option
                     -r reports unit coordinates instead of repeat coordinates
                     -g no reverse complimenting within backwards coordinates
                     -s reports status of progress through standard error output by current unit size for which it is searching
    Purpose:     Finds tandem repeats in genomes submitted via file
    Takes:       fasta sequence file, tab delimited coordinate file with 
                 (ie. gene) start and stop coordinates followed by a comment, 
                 sequence type, and repeat unit size upper and lower limits
    Returns:     Prints tab delimited file of repeat coordinates.
 
    Author:      Robert Leach
    Company:     LANL
    Date:        8/17/2000,8/25/2000,9/29/2000 - unit coords option added
    
end
    exit;
}

#Double check user input...
if(($umax && $umax !~ /^\d+$/) || ($umin && $umin !~ /^\d+$/))
  {die "You've entered an invalid minimum ($umin) or maximum ($umax) unit length.\nIt must be a number\n";}
if(!$umin)
  {$umin = 2;}
if($minunits < 2)
  {die "You've entered an invalid minimum number of units.  By definition, a repeat must have more than one unit!\n";}
$minunits = 2 if(!$minunits);
$minunits--;                      #The minimum number of units is always one less than the 
                                  #desired value because of the way the matching works

#Get sequence from file and process it
unless(open(SEQ,$seq_file))
  {die "Unable to open file: [$seq_file]\n$!\n";}
my($defline,@input);
while(<SEQ>)
  {
    if(/^>/ && $defline eq 'yes')
      {print "tandyman.pl:Error: Only one sequence may be analyzed at a time.  Please edit your sequence file.";}
    if(/^>/)
      {$defline='yes';}
    else
      {push(@input,$_);}
  }
chomp(@input);
close SEQ;

my (@errors,$seq,$unit_size,$firstseries);
$seq = join('',@input);
if($seq =~ />/)
  {die "I appear to have found multiple deflines.  Currently, Tandyman can only handle one sequence at a time.  Please retry with only one sequence.\n";}
$seq =~ s/\s//g;
$seq =~ s/[\$\*]$//;
$seq = uc($seq);
$tenuous = "**Warning: Reverse compliment unreliable. Bad characters in your sequence.**" if($seq =~ /[^$chars]/);
print (length($seq),"\n") if($DEBUG);

#Check the sequence unless error checking has been turned off...
if(!$checkoff)
  {
    local $" = '],[';
    if($chars ne $defchars)
      {@errors = ($seq =~ /[^$chars]/g);}
    elsif(@errors = ($seq =~ /[^$defchars]/g))
      {print STDERR "ERROR: These non-DNA characters were found in the sequence.  They are displayed here in brackets:\n[@errors]\n";}
    if(($chars eq $defchars) && (@errors = ($seq =~ /[^$defpchars]/g)))
      {print STDERR "ERROR: These non-Protein characters were found in the sequence.  They are displayed here in brackets:\n[@errors]\n";}
    exit if(($chars eq $defchars && $seq =~ /[^$defpchars]/ && $seq =~ /[^$chars]/) || ($chars ne $defchars && $seq =~ /[^$chars]/));
  }

#Now that the sequence has been confirmed, set the max unit length (unless set manually)
if(!$umax)
  {
    $length = length($seq);
    $umax = $length / 2;
    $umax =~ s/\..*$//o;
  }

#study the sequence for faster pattern matching...
study($seq);

#Get the coordinates file if it exists
my ($linecount,$start,$stop,@comment,@coord_array,$com,$cycle,@switcheroo,$elem,$un);
if($coord_file)
  {
    unless(open(COORD,"$coord_file"))
      {die "Unable to open file: [$coord_file]\n$!\n";}
    while(<COORD>)
      {
	++$linecount;
	chomp;
	($start,$stop,@comment) = split(/\t/);
	if(@comment)
	  {
	    $comments_provided = 'true';
	    $com = join("\t",@comment);
	  }
	else
	  {$com = $default_comment;}
	if($start !~ /^\d+$/ || $stop !~ /^\d+$/)
	  {
	    print STDERR "ERROR: Non-numeric character(s) found in the coordinate file!\n";
	    print STDERR "Line $linecount: [$start]\n" if($start !~ /^\d+$/);
	    print STDERR "Line $linecount: [$stop]\n" if($start !~ /^\d+$/);
	    die "The first 2 columns may only be numbers seperated by tabs!\n";
	  }
	$low = $start < $stop ? $start : $stop;
	$high = $start > $stop ? $start : $stop;
	$rc = $start > $stop ? 'yes' : 'no';     #reverse compliment
	if(($high-$low) > (length($seq)/2))
	  {
	    push(@coord_array, {'low' => 1, 'high' => $low, 'comment' => $com, 'reverse_compliment' => $rc});
            $low = $high;
	    $high = length($seq);
	  }
	push(@coord_array, {'low' => $low, 'high' => $high, 'comment' => $com, 'reverse_compliment' => $rc});
      }
  }

#Now search for repeats
foreach $unit_size ($umin .. $umax)
  {
    print STDERR "Unit Size: $unit_size  Unit Size Max: $umax\n" if($status);

    #Grab all the repeats plus some extra at the end of each series
    #and go through all the strings of repeats to identify the units
    #and to see if there's an extra portion at the end (which will be
    #recorded as a seperate repeat)
    while($seq =~ /((.{$unit_size})\2{$minunits,})(.{0,$unit_size})/g)
      {
	#Store all the things found
        $series = $1;
	$series_len = length($series);
        $unit_seq = $2;
        $partial_unit = $3;

        #Set-up for next repeat...
	#Reset the position from which to start looking for the next repeat and set the repeat series position.
	$position = pos($seq);
	$series_pos = $position - $unit_size - $series_len + 1;
	pos($seq) = $position - ($unit_size*2) + 1;

	print("New Series Start: ",$series_pos,"\n") if($DEBUG);

	#Filter out units that are just compounded smaller units
	foreach $subunit_size (1..$unit_size)
	  {
	    if($unit_seq =~ /^((.{$subunit_size})\2+)$/)
	      {
		print "Found one that's a compounded smaller unit!: $unit_seq\t$series_pos\t$comment\n" if($DEBUG);
		$compound_flag = 1;
		last;
	      }
	  }
	if($compound_flag)
	  {
	    undef($compound_flag);
	    next;
	  }

	#Determine Copy Number...
	$num_units = $series_len/$unit_size;
	while($partial_unit && $unit_seq !~ /^$partial_unit/)
	  {chop($partial_unit);}
	$partial_len = length($partial_unit);
	$partial_size = $partial_len/$unit_size;
	$partial_print = $partial_size;
	$partial_print =~ s/^0\.(.{0,2}).*$/$1/o;
	$comment = "$unit_seq\t$num_units";
	$comment .= ".$partial_print" if($partial_size);

	#Set-up for printing coordinates (supply unit info if requested)...
	if(!$report_coords)
	  {$series_coords = $series_pos . ".." . ($series_pos+$series_len+$partial_len-1) . "\t";}
	else
	  {
	    undef($series_coords);
	    for($cycle=$series_pos,$un=$num_units;$un>0;--$un,$cycle+=$unit_size)
	      {$series_coords .= $cycle . ".." . ($cycle+$unit_size-1) . "\t";}
	    $series_coords .= $cycle . ".." . ($cycle+$partial_len-1) . "\t" if($partial_len>0);
	  }

	#Check repeat against coord file if one is provided...
	if($coord_file)
	  {
            $rep_l_bound=$series_pos;
            $rep_u_bound=$series_pos+$series_len+$partial_len-1;
	    foreach $hash (@coord_array)
	      {
		#Check if repeat is inside the determined coords...
		if(($rep_l_bound >= $hash->{low} && $rep_l_bound <= $hash->{high}) ||
		   ($rep_u_bound >= $hash->{low} && $rep_u_bound <= $hash->{high}) ||
		   ($rep_l_bound <= $hash->{low} && $rep_u_bound >= $hash->{high})
		  )
		  {
		    push(@coords_found, $hash->{comment});
		    #reverse compliment if & only if:
		    #  the hash flag is set, 
		    #  we're using default chars, 
		    #  we haven't already reverse complimented, 
		    #  AND the user chose to do so...
		    if(($hash->{reverse_compliment}) eq 'yes' &&
		       ($chars !~ /[^$defchars]/) &&
		       !$already_done &&
		       !$norevcomp)
		      {
			#switch the coordinates...
			if(!$report_coords)
			  {$series_coords =~ s/(\d+)\.\.(\d+)/$2\.\.$1/g;}
			else
			  {
			    (@switcheroo) = ($series_coords =~ /(\d+)\.\.(\d+)/g);
			    @switcheroo = reverse(@switcheroo);
			    if($partial_len > 0)
			      {
				@switcheroo = map { $_ -= ($unit_size-$partial_len) } @switcheroo;
				$switcheroo[0] += ($unit_size-$partial_len);
				$switcheroo[$#switcheroo] += ($unit_size-$partial_len);
			      }
			    undef($series_coords);
			    for($elem=0;$elem<$#switcheroo;$elem+=2)
			      {$series_coords .= $switcheroo[$elem] . ".." . $switcheroo[$elem+1] . "\t";}
			  }

			#reverse compliment the unit sequence and shift it to start from the end of the partial unit...
			$new_unit = (reverse($partial_unit)) . (reverse($unit_seq));
			chop($new_unit) while(length($new_unit) > $unit_size);
			$new_unit =~ tr/$chars/$rc_chars/;
			$comment =~ s/^$unit_seq/$new_unit/;
			$comment .= "$tenuous" if($new_unit =~ /[^$chars]/); #Tac on disclaimer if sequence is bad
                        $already_done = 1;
		      }
		  }
	      }
	    undef($already_done);

	    #If the repeat wasn't found in any coords and no comments
	    #were provided in the coords file, use the default comment
	    if(!@coords_found && !$comments_provided)
	      {push(@coords_found, $default_alternate_comment);}
	  }
	$comment .= "\t" . (join("\t",@coords_found));
	undef(@coords_found);
	print "$series_coords$comment\n";
      }
  }

