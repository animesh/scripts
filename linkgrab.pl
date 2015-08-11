#!usr/bin/perl
use LWP::UserAgent;
$file=shift@ARGV;
$filetemp=$file;
$oo=$filetemp=~s/http//g;
if(($oo != 1) or ($file eq "")){die "usage linkgrab.pl websiteaddress\n";} 
open(S,">$file.success.txt");
open(E,">$file.error.txt");
$input="console";
spidez($file,$input);
sub spidez
{
   $f=shift;chomp $f;
   $fo=shift;chomp $fo;
   $localfile=$fo.'-'.$f.'.html';
   $localfile=~s/\//\-/g;
   unless (open(OUT,">$localfile")){print E"ERROR FOR WRITING:$localfile $!\n";exit;}
   $full_path=$f;
   $ua=new LWP::UserAgent;
   $request = new HTTP::Request('GET', $full_path);
   $response = $ua->request($request);
   $content= $response->content;
   unless($response->is_success){die "$full_path,$response->error_as_HTML\n";}
   print OUT $content;close (OUT);print S"$f\n";
}
close F;
close S;close E;
