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

#This is an exmple to be used for select_sdf
# using the -perl_file option

sub is_sdf_record_kept
{
	my $sdf_entry = shift ;
	my $record_number = shift ;
	
	defined $sdf_entry || die "Assertion failed" ;
	defined $record_number || die "Assertion failed" ;
	
	($record_number >= 3) && ($record_number <= 10) ;
}

1;
