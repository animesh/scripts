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

#!usr/bin/perl
use LWP::UserAgent;
print "\nenter the list of things to be downloaded from site";
$f1=<>;
chomp $f1;
open(F,$f1) or die "file not found\n";
open(E,">genecardidERROR.txt");
while($line=<F>)
{$n=1;
 chomp $line;$line=~s/\s+/\t/g;
 if($line ne ""){@allz=split(/\t/,$line);
  foreach $spider(@allz){if($spider eq "" or $spider =~ /^</){next;}
   else{$gc_id=($spider);
   $localfile=$f1.".".$n.'.html';
   
   unless (open(OUT,">$localfile")){print E"ERROR FOR WRITING:$localfile $!\n";exit;}
   $full_path=$spider;#$web_site.'carddisp?'.$gc_id;
   $ua->prepare_request($request);
   $ua=new LWP::UserAgent;
   $request = new HTTP::Request('GET', $full_path);
   $response = $ua->request($request);
   $content= $response->content;
   unless($response->is_success){die "$full_path,$response->error_as_HTML\n";}
   print OUT $content;close (OUT);print E"$gc_id\n";print "$gc_id\n";}
  }
 }undef @allz;$n++;
}
close F;close E;
