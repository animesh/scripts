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

#!/usr/local/bin/perl
# Created by sharma.animesh@gmail.com using
# v 10.3

use Bio::Structure::IO;
use strict;

# Separating  Chain from given a PDB file (Sequence and Structure)


if(@ARGV ne 1){die "USAGE: perl perl_program_name pdb_file_name\n\n";}
my $file=shift @ARGV;
my $structio = Bio::Structure::IO->new(-file => $file);
my $struc = $structio->next_structure;
my $time=time;


my %t2o = (
      'ALA' => 'A',
      'VAL' => 'V',
      'LEU' => 'L',
      'ILE' => 'I',
      'PRO' => 'P',
      'TRP' => 'W',
      'PHE' => 'F',
      'MET' => 'M',
      'GLY' => 'G',
      'SER' => 'S',
      'THR' => 'T',
      'TYR' => 'Y',
      'CYS' => 'C',
      'ASN' => 'N',
      'GLN' => 'Q',
      'LYS' => 'K',
      'ARG' => 'R',
      'HIS' => 'H',
      'ASP' => 'D',
      'GLU' => 'E',
    );



for my $chain ($struc->get_chains) {
     my $chainid = $chain->id;
     my $fn=$file;
     $fn=~s/\.pdb|\.PDB//g;
     my $fnfas=$fn.".$chainid.fas";
     my $fnpdb=$fn.".$chainid.pdb";
     open(FO,">$fnfas");
     open(FPDB,">$fnpdb");

     print FO"\>$file\t\tChain-$chainid\tGenerated @ $time\twith\tBioperl PDB\tParser\n";
	 print FPDB"HEADER\t$file\t$fnpdb\t\t\t$time\n";
     print FPDB"REMARK   Chain-$chainid\tGenerated @ $time with Bioperl PDB\tParser\n";

	 my $res_cnt=0;
     for my $res ($struc->get_residues($chain)) {
        my $resid = $res->id;
		my $resol = uc($resid);
		$resol=~s/[0-9]|-//g;
		my $resolb=$resol;
		$resol = $t2o{$resol};
		$res_cnt++;
		print FO"$resol";
        my @atoms = $struc->get_atoms($res);
		for(my $c2=0;$c2<=$#atoms;$c2++){
			my $cnt_atom=$c2+1;
			my ($xa,$ya,$za) = $atoms[$c2]->xyz;
			my $seriala = $atoms[$c2]->serial;
			my $occupancya = $atoms[$c2]->occupancy;
			my $tempfactora = $atoms[$c2]->tempfactor;
			my $segIDa = $atoms[$c2]->segID;
			my $pdb_atomnamea = $atoms[$c2]->pdb_atomname;
			my $elementa = $atoms[$c2]->element;
			my $chargea = $atoms[$c2]->charge;
			my $atoma=sprintf('%-6s',"ATOM");
			$seriala=sprintf('%5s', $seriala);
			$pdb_atomnamea=sprintf('%4s', $pdb_atomnamea);
			my $residuenamea=sprintf('%4s', $resolb);
			my $chainida=sprintf('%2s', $chainid);
			if($chainida eq "default"){$chainida="";}
			$res_cnt=sprintf('%4s', $res_cnt);
			$xa=sprintf('%8.3f', $xa);
			$ya=sprintf('%8.3f', $ya);
			$za=sprintf('%8.3f', $za);
			$occupancya=sprintf('%6.2f', $occupancya);
			$tempfactora=sprintf('%6.2f', $tempfactora);
			$segIDa=sprintf('%10s', $segIDa);
			$elementa=sprintf('%2s', $elementa);
			$chargea=sprintf('%2s', $chargea);
			print FPDB "$atoma$seriala$pdb_atomnamea$residuenamea$chainida$res_cnt $xa$ya$za$occupancya$tempfactora$segIDa$elementa$chargea\n";
		}
     }
	 print FPDB"MASTER\n";
	 print FPDB"END\n";
	 print FO"\n";
     close FO;
}
close FPDB;