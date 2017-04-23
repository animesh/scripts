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

use Getopt::Std;

getopts('hmf:');

die "Usage: $0 [-h] [-m] [-f string]\n" if ($opt_h);

print "Option M was present\n" if ($opt_m);

print "Option F was passed '$opt_f'\n" if ($opt_f);

print "No options\n" if (!$opt_f && !$opt_m);

