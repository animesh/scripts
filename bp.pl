#!/usr/bin/perl -w

use strict;

die "Usage: blast_parser.pl blast_output_file_name\n" unless @ARGV;
open INFILE, $ARGV[0] or die "Couldn't open infile: $!\n";

my %hits;  # to store all data from this file;
my ($subject_ident, $comment_line, $subject_length);
my ($e_value, $identities, $gaps, $aligned_length, $orientation);
my ($query_start, $query_end, $subject_start, $subject_end);

while (<INFILE>) {   
    chomp;
        # put aligned sequence info onto data for the most recent hit
    if ($subject_ident && exists $hits{$subject_ident}{hit_data} && (/^>/ || /Score =/ || /^Lambda/ ) ) {  # but not for the first hit of the first subject
        push @{ $hits{$subject_ident}{hit_data}[-1] }, $query_start, $query_end, $subject_start, $subject_end;  
        last if (/^Lambda/);  # end of hit processing

        $query_start = $query_end =  $subject_start = $subject_end = 0;  # reset
    }

        # new subject sequence
    if (/^>/) {   # finds the “>” in the first column of the line
        $subject_length = 0;  # reset to 0 
        $comment_line = $_;
        while (1) {  # endless loop to get all of comment line
            my $next_line = <INFILE>;
            if ($next_line =~ /Length = (\d+)/ ) {
                $subject_length = $1;
                last;  # break out of loop
            }
            else {  # continuation of comment line
                chomp $next_line;
                $next_line =~ s/^\s+/ /; # remove leading
                $next_line =~ s/\s+$/ /; # and trailing multiple spaces
                $comment_line .= $next_line;
            }  # end else
        }  # end while(1) loop
        $comment_line =~ />(\S+)\s/g;  
        $subject_ident = $1;
        $hits{$subject_ident}{subject_length} = $subject_length;
        $hits{$subject_ident}{comment_line} = $comment_line;
    } # end subject sequence info section
  
        # new hit
    if (/Score = /) {
        my $score_line = $_;
        my $identities_line = <INFILE>;
        my $strand_line = <INFILE>;

              # now process the information in these 3 lines
        $score_line =~ /Score.*Expect = ([-.e\d]+)/;  # note the regex here!
        $e_value = $1;

        $identities_line =~ /Identities = (\d+)\/(\d+)/;  # note the escaped slash  
        ($identities, $aligned_length) = ($1, $2);
        $gaps = 0;  # set a default
        if ($identities_line =~ /Gaps = (\d+)/ ) {  # Gaps are not always present
            $gaps = $1;
        }

        $orientation = 'Plus';
        if ($strand_line =~ /Plus \/ (Plus|Minus)/) {  # only for blastn
            $orientation = $1;
        }
        push @{ $hits{$subject_ident}{hit_data} }, [$e_value, $identities, $gaps, $aligned_length, $orientation];
    }  # end if /Score/

        # aligned sequence info
    if (/^Query/) {
        my $query_line = $_;
        my $match_line = <INFILE>;
        my $subject_line = <INFILE>;

        $query_line =~ /Query:\s*(\d+)\D+(\d+)\s*$/;
        $query_start = $1 unless $query_start;
        $query_end = $2;

        $subject_line =~ /Sbjct:\s*(\d+)\D+(\d+)\s*$/;  # note wierd spelling
        $subject_start = $1 unless $subject_start;
        $subject_end = $2;
    }  # end /^Query/

}  # end while <INFILE> loop 
        

    # print out the info
foreach my $subject_ident (sort keys %hits) {
    print "$subject_ident:\n";
    print "     $hits{$subject_ident}{comment_line}\n";
    print "     Length = $hits{$subject_ident}{subject_length}\n";

    foreach my $hit ( @{$hits{$subject_ident}{hit_data}} ) {
        print "          @$hit\n";
    }
    print "\n";
}

