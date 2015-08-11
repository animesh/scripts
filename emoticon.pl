#!/tools/perl/current/bin/perl -w

use Emoticon();
use strict;

#####################################################################
#
#    PROGRAM: emoticon.pl
#    PURPOSE: Driver for the Emoticon.pm module for illustrating simple
#             objected-oriented  Perl.
#     AUTHOR: Steve A. Chervitz (sac@genome.stanford.edu)
#     SOURCE: http://genome-www.stanford.edu/~sac/perlOOP/examples/
#    CREATED: 1 July 1997
#   MODIFIED: sac --- Wed Aug 20 15:52:26 1997
#
#####################################################################

my $emoticon1 = new Emoticon();
my $emoticon2 = new Emoticon(-face=>';^]');

printf "EMOTICON 1: %s\n\n", $emoticon1->emote;
printf "EMOTICON 2: %s\n\n", $emoticon2->emote;

$emoticon1->frown;
$emoticon2->mouth('>');

printf "EMOTICON 1 FROWNING: %s\n\n", $emoticon1->emote;
printf "EMOTICON 2 WITH NEW MOUTH: %s\n\n", $emoticon2->emote;

exit();
