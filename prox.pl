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

use warnings;
use strict;
use Test::More tests => 8;

BEGIN {
    use_ok( 'WWW::Mechanize' );
}
my $t = WWW::Mechanize->new();
use proxy;
$t=p1::p1($t);

isa_ok( $t, 'WWW::Mechanize', 'Created the object' );

my $response = $t->get( "http://www.google.com/");
isa_ok( $response, 'HTTP::Response', 'Got back a response' );
ok( $response->is_success, 'Got google' ) or die "Can't even fetch google";
ok( $t->is_html );

$t->field(q => "foo"); # Filled the "q" field

$response = $t->click("btnG");
isa_ok( $response, 'HTTP::Response', 'Got back a response' );
ok( $response->is_success, "Can click 'btnG' ('Google Search' button)");

like($t->content, qr/foo\s?fighters/i, "Found 'Foo Fighters'");
