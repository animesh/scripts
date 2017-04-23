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

use strict;
use Music::Scales;


my @maj = get_scale_notes('Eb');           # defaults to major
print join(" ",@maj),"\n";                 # "Eb F G Ab Bb C D Eb"
my @blues = get_scale_nums('bl');		   # 'bl','blu','blue','blues'
print join(" ",@blues),"\n";               # "0 3 5 6 7 10"
my %min = get_scale_offsets ('G','mm',1);  # descending melodic minor
print map {"$_=$min{$_} " } sort keys %min;# "A=0 B=-1 C=0 D=0 E=-1 F=0 G=0"

