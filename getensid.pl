use strict;
use warnings;
use LWP::Simple;
use WWW::Mechanize;
my $query=shift @ARGV;
chomp $query;
print $query;
my @collurl;
my $purl = 'http://www.ensembl.org/Multi/Search/Results?species=all;idx=;q='.$query.'%201';
  #my $url= 'http://www.ensembl.org/Bos_taurus/Search/Details?species=Bos_taurus;idx=Gene;end=14;q=histone%20h2a%20histone%20cluster%201';
#/Xenopus_tropicalis/Search/Details?species=Xenopus_tropicalis;idx=Gene;end=15;q=histone h2a histone cluster 1 1
my $contentrec=GURL($purl);
my $contentrec=MURL($purl);
sub GURL{
  my $url=shift;
  my $content = get $url;
  die "Couldn't get $url" unless defined $content;

  # Then go do things with $content, like this:

  if($content =~ m/jazz/i) {
    print "They're talking about jazz today on Fresh Air!\n";
  }
  else {
    print "Fresh Air is apparently jazzless today.\n";
  }
  return $content;
}
sub MURL{
  my $url=shift;
my $mech = WWW::Mechanize->new();
$mech->get( $url );
my @links = $mech->links();
for my $link ( @links ) {
    printf "%s, %s\n", $link->text, $link->url;
	push(@collurl,'http://www.ensembl.org'.$link->url.'%201');
}
return @links;
}
print @collurl;
