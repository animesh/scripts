use strict;
use warnings;
use WWW::Mechanize;
my $query=shift @ARGV;
chomp $query;
my %collurl;
my $purl = 'http://www.ensembl.org/Multi/Search/Results?species=all;idx=;q='.$query;
my $contentrec=MURL($purl);
sub MURL{
  my $url=shift;
  my $mech = WWW::Mechanize->new();
  $mech->get( $url );
  my @links = $mech->links();
  for my $link ( @links ) {
	my $ltxt=$link->text;	
	if($ltxt){
	if($ltxt=~/Gene /){
	my $lurl=$link->url;
	$collurl{$link->text}='http://www.ensembl.org'.$lurl;
	}}
  }
}
foreach (keys  %collurl){
	$collurl{$_}=~s/ /\%20/g;
	print "$_\t$collurl{$_}\n";
	my $mech = WWW::Mechanize->new();
	$mech->get($collurl{$_});
	my $ltext=$mech->text();
	while($ltext =~ /\[ Ensembl(.*)\]/g) {
		print "$1\n";
	}
}
