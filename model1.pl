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


sub gene_model($)
{
$seq=shift(@_);
@seq=split(//,$seq);
@start_codon= qw(ATG atg);
@stop_codon=qw(TAA TAG taa tag tga);
@gene=();
@start_index=();
@stop_index=();

for($i=0;$i<$length_of_seq-2;$i++)
{

  $codon=$seq[$i].$seq[$i+1].$seq[$i+2];
  foreach $start_codon (@start_codon)
  {

    if($codon eq $start_codon)
    {
      $start_found+=1;
      @start_index=(@start_index,$i);
      last;	
    } ###End if
  } ## End foreach
  foreach $stop_codon (@stop_codon)
  {
    if($codon eq $stop_codon)
    {

      $stop_found+=1;
      @stop_index=(@stop_index,$i);
      last;
    }
  }

}

foreach $stop_index (@stop_index)
{
  foreach $start_index (@start_index)
  {
    $end=$stop_index;
    $difference= $stop_index-$start_index;
    if($difference% 3==0 && $difference>60)
    {
      $start=$start_index;
      @gene=(@gene,$start,$end);
      last;
    }
  }
}

}# End sub-routine
