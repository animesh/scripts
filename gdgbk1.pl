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

#!/usr/bin/perl

  use strict;
  use lib "$ENV{HOME}/projects/bioperl-live";
  use Bio::Graphics;
  use Bio::SeqIO;
  use Bio::SeqIO;
  my $file = shift                       or die "provide a sequence file as the argument";
  my $io = Bio::SeqIO->new(-file=>$file) or die "couldn't create Bio::SeqIO";
  my $seq = $io->next_seq                or die "couldn't find a sequence in the file";

  my @features = $seq->all_SeqFeatures;

  # sort features by their primary tags
  my %sorted_features;
  for my $f (@features) {
    my $tag = $f->primary_tag;
    push @{$sorted_features{$tag}},$f;
  }

  my $panel = Bio::Graphics::Panel->new(
                                        -segment   => $seq,
                                        -key_style => 'between',
                                        -width     => 800,
                                        -pad_left  => 10,
                                        -pad_right => 10,
                                        );
  $panel->add_track($seq,
                    -glyph => 'arrow',
                    -bump => 0,
                    -double=>1,
                    -tick => 2);

  $panel->add_track($seq,
                    -glyph  => 'generic',
                    -bgcolor => 'blue',
                    -label  => 1,
                   );

  # general case
  my @colors = qw(cyan orange blue purple green chartreuse magenta yellow aqua);
  my $idx    = 0;
  for my $tag (sort keys %sorted_features) {
    my $features = $sorted_features{$tag};
    $panel->add_track($features,
                      -glyph    =>  'generic',
                      -bgcolor  =>  $colors[$idx++ % @colors],
                      -fgcolor  => 'black',
                      -font2color => 'red',
                      -key      => "${tag}s",
                      -bump     => +1,
                      -height   => 8,
                      -label    => 1,
                      -description => 1,
                     );
  }

  print $panel->png;
  exit 0;