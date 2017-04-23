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

#!/usr/bin/perl -w

use ExtUtils::testlib;

use strict;

use Audio::Ecasound qw(:simple);

on_error('');
$_ = eci("
         cs-add play_chainsetup
        c-add 1st_chain
        -i:some_file.wav
        -o:/dev/dsp
        cop-add -efl:100
        cop-select 1
        copp-select 1
        cs-connect
        start
");
if(!defined) {
    die "Setup error, you need 'some_file.wav' in the current directory\n\n"
            . errmsg();
}

on_error('die');
my $cutoff_inc = 500.0;
while (1) {
    sleep(1);
    last if eci("engine-status") ne "running";

    my $curpos = eci("get-position");
    last if $curpos > 15;

    my $next_cutoff = $cutoff_inc + eci("copp-get");
    eci("copp-set", $next_cutoff);
}
eci("stop");
eci("cs-disconnect");
print eci("cop-status"), "\n";
