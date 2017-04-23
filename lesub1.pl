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
         use LWP::UserAgent;
         use HTML::LinkExtor;
         use URI::URL;
	 use proxy;
	 $l1=shift;
         undef $/;
	open(FILE, $l1);
	$url = <FILE>;
	close(FILE);
 	 $ua = LWP::UserAgent->new;
	 $ua=p1::p1($ua);
	 my @href = ();
         sub callbacka {
            my($tag, %attr) = @_;
            return if $tag ne 'a';  # we only look closer at <img ...>
            push(@href, values %attr);
         }
         $p = HTML::LinkExtor->new(\&callbacka);
         $res = $ua->request(HTTP::Request->new(GET => $url),
	 sub {$p->parse($_[0])});
	 my $base = $res->base;
         @imgs = map { $_ = url($_, $base)->abs; } @imgs;
	 @href = map { $_ = url($_, $base)->abs; } @href;
	 print join("\n", @href), "\n";

