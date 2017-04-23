#!/usr/bin/perl
	   use WWW::Mechanize;
	   use LWP::UserAgent;
           my $agent = WWW::Mechanize->new();
	   $agent->proxy(['http', 'ftp'] => 'http://animesh_sharma:Infosys123@192.168.100.25');
           $agent->get($url);

           $agent->follow_link( 'n' => 3 );
           $agent->follow_link( 'link_regex' => qr/download this/i );
           $agent->follow_link( 'url' => 'http://host.com/index.html' );

           $agent->submit_form(
               'form_number' => 3,
               'fields'      => {
                                   'user_name'  => 'yourname',
                                   'password'   => 'dummy'
                               }
           );

           $agent->submit_form(
               'form_name' => 'search',
               'fields'    => {
                               'query'  => 'pot of gold',
                               },
               'button'    => 'Search Now'
           );
