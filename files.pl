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

=head1 DESCRIPTION

Just a small utility script that sets up some variables and cleans up
some files before each test.  We normally start by deleting files used
by the progrms during their work so that we have repeatable and
reliable state.

We create the file .cgi-infostruc.pl.

=cut

use Cwd;

$verbose=0 unless defined $verbose;

print STDERR "fixing up files; the current directory is ", cwd, "\n"
  if $verbose & 8;

#setup files for start of tests everything ends in a ~ so it is
#deleted by make clean with no further thought.

$conf='link-cont-conf.test-tmp~';
$blib=cwd . '/blib'; $script=$blib . '/script';
$lonp='link_on_page.cdb.test-tmp~'; $phasl='page_has_link.cdb.test-tmp~';
$urls='urllist.test-tmp~'; $linkdb='links.test-tmp.bdbm~';
$sched='schedule.bdbm.test-tmp~';

$lock="#$linkdb.lock";

@unlink=( $conf, $lonp, $phasl, $urls, $linkdb, $sched, $lock);
unlink @unlink;

-e $_ and die "couldn't unlink $_" foreach @unlink;

open (CONFIG, ">$conf") or die "can't open conf file: $conf";
print CONFIG <<"EOF";
\$::links="$linkdb";
\$::page_index="$phasl";
\$::link_index="$lonp";
\$::schedule="$sched";
EOF

defined $::infos and do {
  print CONFIG "\$::infostrucs='$::infos';\n";
};
  print CONFIG "1;\n";

close CONFIG  or die "can't close conf file: $conf";;

3921;
