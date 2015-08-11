#!/usr/local/bin/perl

#$path ="./";
$path = "";
$file = $path . "nrtosp.dat";
open(FILE,"$file") || die("Can't open file nrtosp.dat for input\n");

@lines = <FILE>;		#Read file into an array
close(FILE);
chop(@lines);			#remove newline from each line
foreach $line (@lines)
{
	$line =~ tr/,/|/;	#translate , to | so assoc. array works
	@temp1 = split(/&/, $line);
	push(@temp2,@temp1);
}
%list = @temp2;			#associative array of files and substitutions

$pathchar = '/';
$outstring = ".G";
# default file ending appended if no output path specified

print STDOUT 'Input files spec, including wildcards [*]: ';
$inspec = <STDIN>;

if ($inspec eq "\n") { $inspec = "*"; } else { chop($inspec); }
# remove the newline

print STDOUT "Path (not including filename) for output [.$pathchar]: ";
$outpath = <STDIN>;
if ($outpath eq "\n") { $outpath = ".$pathchar"; $nopath = 1;}
    else { chop($outpath); $nopath = 0;}
# If outpath doesn't end with the path character, append it
if ($outpath !~ m/$pathchar$/) { $outpath .= $pathchar; }

@infiles = <${inspec}>;

if (!defined(@infiles)) {
  die("No files found matching input pattern $inspec\n");
}

foreach $infile (@infiles) {
  if (!(-e $infile)) {
    print STDERR "File $infile does not exist, continuing\n";
    next;
  }

  if (-z $infile) {
    print STDERR "File $infile has zero size, continuing\n";
    next;
  }

  open(INFILE,"<$infile") || die("Can't open file $infile for input\n");
# < means read only
  $outfile = $infile;

  # Pick out file name from possible path specification
  $infile =~ m/([^$pathchar]+)$/;
  $outfile = $1;
  if ($nopath) {$outfile .= $outstring;}
  # Takes the name to be the last sequence of non-path characters

  $outfile = "$outpath$outfile";
  open(OUTFILE,">$outfile") || die("Can't open file $outfile for output\n");
# > means write only, creates new file if needed, or else wipes old file

	$flag = 0;
	while (($file, $subst) = each(%list))   #loop over filenames
	{
		if ($file eq $1) {
			$subst =~ tr/|/,/;	#undo translation
			@temp = split(/:/, $subst);
			$flag = 1;
#note: can't jump out of while with a last function here. each() is buggy.
		}
	}

  foreach $line (<INFILE>) {
	if ($flag == 1) {$line =~ s/$temp[0]/$temp[1]/;}
    print OUTFILE $line;
  }

  close(INFILE);
  close(OUTFILE);
}
