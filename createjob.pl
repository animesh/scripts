#!/usr/bin/perl
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

system("ls -1 *.fas > temp");
open(T,"temp");
$command="blastcl3";
while($l=<T>){
	chomp $l;
	$l=~s/\.\.\///;
	push(@tem,$l);
	
}

foreach $f (@tem){
	@tem2=split(/\./,$f);
	$pbsfn=fttil.".".@tem2[6].".pbs";
        $perlfn=blast2ncbi.".".@tem2[6].".pl";
	open(FPBS,">$pbsfn");
	print FPBS"#! /bin/sh -\n";
	print FPBS"#PBS -N \"fttil@tem2[6]\"\n";
	print FPBS"#PBS -A informatikk\n"; 
	print FPBS"#PBS -l ncpus=1,walltime=72:00:00\n";
	print FPBS"#PBS -l mem=512mb\n";
	print FPBS"#PBS -o fttil@tem2[6]job.out\n";
	print FPBS"#PBS -e fttil@tem2[6]job.err\n";
	print FPBS"cd /home/fimm/ii/ash022/ft/fttilrb\n";
	print FPBS"./$perlfn\n";
	close FPBS;
        open(FPMG,">$perlfn");
	print FPMG"\#\!\/usr\/bin\/perl\nsystem(\"$command -p blastn -d nr -i $f -o $f.$command.out\")\n";
	close FPMG;
	system("chmod 755 $perlfn");
        system("qsub $pbsfn");
 }

