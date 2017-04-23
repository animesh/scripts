  use Bio::Graphics::Panel;

  # Create a series of Bio::SeqFeature objects. In this example, we use AcePerl
  use Ace::Sequence;  # or any Bio::Seq factory
  my $db     = Ace->connect(-host=>'brie2.cshl.org',-port=>2005) or die;
  my $cosmid = Ace::Sequence->new(-seq=>'Y16B4A',
                                  -db=>$db,-start=>-15000,-end=>15000) or die;
  my @transcripts = $cosmid->transcripts;

  # Let the drawing begin...
  my $panel = Bio:Graphics::Panel->new(
                                      -segment => $cosmid,
                                      -width  => 800
                                     );


  $panel->add_track(arrow => $cosmid,
                  -bump => 0,
                  -tick=>2);

  $panel->add_track(transcript => \@transcripts,
                    -bgcolor   =>  'wheat',
                    -fgcolor   =>  'black',
                    -key       => 'Curated Genes',
                    -bump      =>  +1,
                    -height    =>  10,
                    -label     =>  1);

  print $panel->png;

