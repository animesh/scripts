#!/usr/bin/perl

$fs = shift @ARGV;
open F,$fs;
while($l = <F>){
	chomp $l;
	if($l ne ""){
	$l=~s/\-//g;
	push(@list,$l);}
	}
close F;

#print @list;
foreach (@list){
 use LWP::UserAgent;#$a=$ENV{'env_pro'}."\:".$ENV{'env_pas'};
 $gif="http://webbook.nist.gov/cgi/cbook.cgi?Struct=C".$_;
 $fff=$_.".gif";
 open F,">$fff";undef @temp;print "$get\t$gif\t$_\t$fff\n";
 $tcpip="http\:\/\/".$ENV{'env_pro'}."\:".$ENV{'env_pas'}."\@192.168.100.25";
 $get=$gif;if( $get !~ /^http/ ){$get="http\:\/\/".$get;}
 $ua = LWP::UserAgent->new;$ua->proxy(['http', 'ftp'] => 'http://animesh_sharma:Infosys123@192.168.100.25');
 #$ua = LWP::UserAgent->new;$ua->proxy(['http', 'ftp'] => 'http://'.$a.'@192.168.100.25');
 #$ua = LWP::UserAgent->new;$ua->proxy(['http', 'ftp'] => $tcpip);
 $req = HTTP::Request->new( GET , $get );
 $res = $ua->request($req);
 print F $res->content if $res->is_success ;
 close F;
}
undef @list;