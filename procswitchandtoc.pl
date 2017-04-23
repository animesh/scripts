#!/usr/bin/perl -w

# procswitchandtoc.pl
#    created as dafxproctoc.pl by Marc Zadel, 2006-04-28
#    modified for confproc.cls by Vincent Verfaille, 2007-08-08
# Execute as
# ./procswitchandtoc.pl < intputfile.txt >

use strict;
use Text::ParseWords;
open(SWI, ">expapersswitch.tex"); #open for write, overwrite
open(SESSIONS, ">exsessions.tex"); #open for write, overwrite

# ----- Configuration
# field separator for the input file
my $fieldseparator=',';

# mac line endings: "\r"  / Unix line endings: :\n"
$/ = "\n";  # line endings for the input file
$\ = "\n";  # line endings for the output file

# ----- Subroutines
# -- split one line of input into a hash with named fields
sub parseinputline {
  my ($inputline) = @_;

  # escape single quotes on the input line: they interfere with quotewords()'s
  # quote handling (ie, they start to quote stuff)
  $inputline =~ s/'/\\'/g;

  # parse the input line
  my @wordlist = &quotewords($fieldseparator, 0, $inputline);

  # replace accented characters with latex escaped equivalents. To be done after
  # quotewords() so the '\' don't get interpreted by quotewords() as escapes
  foreach my $word ( @wordlist ) {
    if ( $word ) { $word = &latexifyaccentedcharacters($word); }
  }

  # extract the fields into local variables. Author names stored as a list
  my ($type, $number, $pcdecision, $nbpages, $title, $filename,
      $generatedfrom, $cite) = @wordlist;

  # remove the first 8 elements (just parsed out), leaving only author names.
  # reminder: list of 8 scalars, though some may be "" if less than 4 authors
  splice( @wordlist, 0, 8 );

  # store the author names as a list of lists. We end up with a list that looks
  #  like ((Udo,Zoelzer),(Daniel,Arfib))
  my @authors = ();
  while ( $wordlist[0] ) {
    push( @authors, [splice( @wordlist, 0, 2 )] );
    # "splice( @wordlist, 0, 2 )": cuts the first 2 scalars off of @wordlist
    # and returns them; calling [splice(@wordlist,0,2)] returns a *reference*
    # to a list containing the first two scalars. (see perldoc perldsc.)
  }

  # create a hash reference containing the named fields and return it
  my $fields = {
    type    => $type,
    number    => $number,
    pcdecision  => $pcdecision,
    nbpages     => $nbpages,
    title     => $title,
    generatedfrom => $generatedfrom,
    filename  => $filename,
    cite    => $cite,
    authors   => \@authors,
  };
  return $fields;
}

# -- takes a string in Mac OS Roman encoding and encode the accented
#  characters with latex escapes (only for a subset of available characters).
sub latexifyaccentedcharacters {
  # for mapping between unicode and mac os western encoding, see:
  # http://www.unicode.org/Public/MAPPINGS/VENDORS/APPLE/ROMAN.TXT
  my ($inputstring) = @_;
  $inputstring =~ s/\x8a/\\"a/g;  # \"a: unicode 0xe4, mac os western 0x8a
  $inputstring =~ s/\x87/\\'a/g;  # \'a: unicode 0xe9, mac os western 0x87
  $inputstring =~ s/\x88/\\`a/g;  # \`a: unicode 0xe8, mac os western 0x88
  $inputstring =~ s/\x8e/\\'e/g;  # \'e: unicode 0xe9, mac os western 0x8e
  $inputstring =~ s/\x8f/\\`e/g;  # \`e: unicode 0xe8, mac os western 0x8f
  $inputstring =~ s/\x91/\\"e/g;  # \"e: unicode 0xeb, mac os western 0x91
  $inputstring =~ s/\x97/\\'o/g;  # \'o: unicode 0xf3, mac os western 0x97
  $inputstring =~ s/\x98/\\`o/g;  # \`o: unicode 0xf2, mac os western 0x98
  $inputstring =~ s/\x9a/\\"o/g;  # \"o: unicode 0xf6, mac os western 0x9a
  $inputstring =~ s/\x99/\\^o/g;  # \^o: unicode 0xf4, mac os western 0x99
  $inputstring =~ s/\xbf/\\o /g;  # \o:  unicode 0xf8, mac os western 0xbf
  $inputstring =~ s/\x96/\\~n /g;  # \~n:  unicode 0xF1, mac os western 0x96
  $inputstring =~ s/\x94/\\^{\\i}/g;  # \^{\i}: unicode 0xee, mac os western 0x94
  $inputstring =~ s/\x/\\i/g;  # \i: unicode , mac os western
  $inputstring =~ s/\x9f/\\"u/g;  # \"u: unicode 0xfc, mac os western 0x9f
  $inputstring =~ s/\x5c/\\/g;  # \: unicode 0x5C, mac os western 0x5C

  return $inputstring;
}

# -- output the information for a day
sub outputdaylatex {
  my ($fields) = @_;
  my $sessiontitle = $fields->{'title'};
  open(SESSIONS, ">>exsessions.tex"); #open for append
  print SESSIONS ' ';
  print SESSIONS '%%%== Day';
  print SESSIONS '\procday{', $sessiontitle, '}'
}

# -- output the information for a session line
sub outputsessionlatex {
  my ($fields) = @_;
  my $sessiontitle = $fields->{'title'};
  open(SESSIONS, ">>exsessions.tex"); #open for append
  print SESSIONS ' ';
  print SESSIONS '%%%-- session';
  print SESSIONS '\session{', $sessiontitle, '}'
}

# -- in: ref. to a list of lists of author names ((Udo,Zoelzer),(Daniel,Arfib))
# out: ref. to a Perl list w/ entries "Udo Zoelzer" and "Daniel Arfib" (no quotes)
sub authorsbyfirstname {
  my ($authors) = @_;
  # generate a list of full "first last" author names
  my @authorlistbyfirstname = map { "$_->[0] $_->[1]" } @$authors;
  return \@authorlistbyfirstname; # return a ref. to the new list of authors
}

# -- in: ref. to a list of lists of author names ((Udo,Zoelzer),(Daniel,Arfib))
# out: ref. to a Perl list w/ entries "Zoelzer, Udo" and "Arfib, Daniel"
sub authorsbysurname {
  my ($authors) = @_;
  # generate a list of authors with surnames written first
  my @authorlistbysurname = map { "$_->[1], $_->[0]" } @$authors;
  return \@authorlistbysurname; # return a ref. to the new list of authors
}

# -- in: ref. to a list of author names: "Zoelzer, Udo" and "Arfib, Daniel"
# out: LaTeX index entries: "\index{Zoelzer, Udo}\index{Arfib, Daniel}"
sub genindex {
  my ($authorsbysurname) = @_;
  my @indexentries = map { "\\index{$_}" } @$authorsbysurname;
  return join('', @indexentries);
}

# -- in: ref. to a list of author names: "Zoelzer, Udo" and "Arfib, Daniel"
# out: bookmarks cmds: "\pdfbookmark[2]{Udo Zoelzer}{#2.Udo Zoelzer}
# \pdfbookmark[2]{Daniel Arfib}{#2.Daniel Arfib}"
sub genbookmark {
  my ($authorsbyfirstname) = @_;
  my @indexentries = map { "\\pdfbookmark[2]{$_}{#2.$_}" }
      @$authorsbyfirstname;
  return join('', @indexentries);
}

# -- output the information for a paper line
sub outputpaperlatex {
  my ($fields) = @_;
  open(SWI, ">>expapersswitch.tex"); #open for append
  print SWI '%=========== PAPER ID = ', $fields->{'number'}, ' ===========';
  print SWI '\ifnum\paperswitch=', $fields->{'number'};
  print SWI '  \procinsertpaper{\LaTeXxShift{} \LaTeXyShift}{',
    $fields->{'nbpages'}, '}{\paperswitch}%';
  print SWI '  {', $fields->{'title'}, '}% paper title';
  print SWI '  {', join( ', ', @{&authorsbyfirstname($fields->{'authors'})}),
  '}% list of authors';
  print SWI '  {', &genindex(&authorsbysurname($fields->{'authors'})),
  '}% authors index entries';
  print SWI '  {', $fields->{'cite'}, '}% cited bib items';
#  print SWI '  {#2}{\paperbookmark}';
  print SWI '  {#2}{', &genbookmark(&authorsbyfirstname($fields->{'authors'})),'}';
  print SWI '\fi';
  print SWI ' ';
  open(SESSIONS, ">>exsessions.tex"); #open for write, overwrite
  print SESSIONS '\paperid{', $fields->{'number'}, '}{', $fields->{'filename'}, '}';
}

# ----- Main
# FIXME: parse a line, and confirm that all of the fields are set up properly
# --> correct number of fields, and the fields have the correct values
open(SWI, ">>expapersswitch.tex"); #open for write, overwrite
print SWI '\newcommand{\paperid}[2]{';
print SWI ' ';
print SWI '\renewcommand{\paperswitch}{#1}';
print SWI ' ';

while ( <> ) {
  chomp; # clear the newline character from the end of the line
  my $fields = &parseinputline($_);   # parse the line into fields
  # take some action depending on what type of line it is; case insensitive
  if ( lc($fields->{'type'}) eq lc('day') ) {
  &outputdaylatex($fields);
  } elsif ( lc($fields->{'type'}) eq lc('session')
      || lc($fields->{'type'}) eq lc('paper session')
      || lc($fields->{'type'}) eq lc('demo session')
      || lc($fields->{'type'}) eq lc('poster session') ) {
  &outputsessionlatex($fields);
  } elsif ( lc($fields->{'type'}) eq lc('oral')
      || lc($fields->{'type'}) eq lc('paper')
      || lc($fields->{'type'}) eq lc('demo')
      || lc($fields->{'type'}) eq lc('poster') ) {
  &outputpaperlatex($fields);
  } elsif ( lc($fields->{'type'}) eq lc('Type')) {
  } else { print '!!! a day, session or paper (',
      $fields->{'type'},') is lost by the script...';
  }
open(SWI, ">>expapersswitch.tex"); #open for append
}
print SWI '}';
close(SWI);
close(SESSIONS);
