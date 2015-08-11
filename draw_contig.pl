#!/usr/bin/perl

use strict;
use Bio::Graphics::Panel;
use Bio::Graphics::Feature;

chomp (my $CLASS = shift);
$CLASS or die "\nUsage: draw_contig.pl IMAGE_CLASS
\t- where IMAGE_CLASS is one of GD or GD::SVG
\t- GD generate png output; GD::SVG generates SVG.\n";

my $ftr = 'Bio::Graphics::Feature';
my $segment = $ftr->new(-start=>-100,-end=>1000,-name=>'ZK154',-type=>'clone');
my $zk154_1 = $ftr->new(-start=>-50,-end=>800,-name=>'ZK154.1',-type=>'gene');

my $xyz4 = $ftr->new(-segments=>[[40,80],[100,120],[200,280],[300,320]],
		     -name=>'xyz4',
		     -subtype=>'predicted',-type=>'alignment');







my $panel = Bio::Graphics::Panel->new(
#				      -grid => [50,100,150,200,250,300,310,320,330],
				      -gridcolor => 'lightcyan',
				      -grid => 1,
				      -segment => $segment,
#				      -offset => 300,
#				      -length  => 1000,
				      -spacing => 15,
				      -width   => 600,
				      -pad_top  => 20,
				      -pad_bottom  => 20,
				      -pad_left => 20,
				      -pad_right=> 20,
#				      -bgcolor => 'teal',
#				      -key_style => 'between',
				      -key_style => 'bottom',
				      -image_class => $CLASS,
				     );
my @colors = $panel->color_names();
my $gd    = $panel->gd;
my @boxes = $panel->boxes;
my $red   = $panel->translate_color('red');
for my $box (@boxes) {
  my ($feature,@points) = @$box;
#  $gd->rectangle(@points,$red);
}

my $type = ($CLASS eq 'GD') ? 'png' : 'svg';
print $gd->$type;

