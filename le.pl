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

	   use HTML::TokeParser::Simple;
           my $p = HTML::TokeParser::Simple->new( $f );

        	while ( my $token = $p->get_token ) {
            	#This prints all text in an HTML doc (i.e., it strips the HTML)
            	next unless $token->is_tag;
		$t1=$token->as_is;
            		if($t1 =~ /\<a\ href/){
			#print $token->as_is; print "a href \n";
			@temp=split(/"/,$t1);foreach (@temp){$_=~s/\s+//g;
				if($_ =~ /^http/ and $_ =~ /\?/ )
					{print "href-$_\n";
