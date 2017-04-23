#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/local/bin/perl
# Time-stamp: "1999-07-17 15:15:19 MDT"

use MIDI::Simple .7;
new_score;

text_event "Title: Four Minutes Thirty-Three Seconds";
text_event "Composer: John Cage (1952)";
copyright_text_event 
    "Copyright 1999 by Sean M. Burke sburke\@netadventure.net";

set_tempo 1_000_000;
 # one qn per second (i.e., per 1 million microseconds)

noop qn;
 # sets $Duration to number of ticks in a qn
my $second = $Duration;

patch_change 0, 115;
  # channel 0, patch 115 (Woodblock)
noop c1, f, o5, C;
#noop d1, v1, c0, c1;
  # imperceptibly short and quiet C1 on channel 0

# It turns out that some sequencers freak out when there's
# a MIDI file that takes time but has no note events.
# So I use this hopefully inaudible event to punctuate the
# silence, for the sequencers' sake.

n;

text_event "First Movement: 30\"";
$Time += $second * 30 - 1;
n;

text_event "Second Movement: 2'23\"";
$Time += $second * ( 2 * 60 + 23) - 1;
n;

text_event "Third Movement: 1'40\"";
$Time += $second * ( 1 * 60 + 40) - 2;
n;

write_score "c433.mid";
exit;

__END__
