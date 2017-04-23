#!usr/bin/perl
use strict;
use LWP::UserAgent;
print "ENTER THE FILE NAME CONTAINING 4 LETTER PDB
ENTRIES :";
my $input=<STDIN>;
chomp $input;
unless(open(INP,$input))
{print" ERROR IN OPENING THE FILE $input: $!\n";exit;}
my @ids=<INP>;
close INP;
foreach my $pdb_id(@ids)
{
 chomp $pdb_id;
 $pdb_id=~ tr/a-z/A-Z/;

 my
$web_site='http://www.rcsb.org/pdb/cgi/export.cgi/';
 my
$full_path=$web_site.$pdb_id.'.pdb?format=PDB&pdbId='.$pdb_id.'&compression=None';
 #print "$full_path\n";
 my $ua=new LWP::UserAgent;
 my $request = new HTTP::Request('GET', $full_path);
 my $response = $ua->request($request);
 my $content= $response->content;
 unless($response->is_success)
    { die "$full_path,$response->error_as_HTML\n";}
 print $content;
} # FOREACH CLOSES
