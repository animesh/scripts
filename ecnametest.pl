#!/usr/bin/perl
if( @ARGV ne 2){die "\nUSAGE\t\"ProgName SeparatedSeqFile\t AnnotationFile\n\n\n";}
$filess = shift @ARGV;$cp=0;$cnp=0;
$fileas = shift @ARGV;$cp=0;$cnp=0;
open (F1, $filess) || die "can't open \"$filess\": $!";
open (F2, $fileas) || die "can't open \"$fileas\": $!";
while ($line = <F1>) 	{
			chomp ($line);
             		push(@name1,$line);
            		}
while ($line = <F2>)    {
                        chomp ($line);
                        push(@name2,$line);
                        }

open (F,">$filess.".".$fileas");
foreach $n1 (@name1){
	@temp1=split(/\s+/,$n1);
	$t1=@temp1[1];
	foreach $n2 (@name2){
	        @temp2=split(/\s+/,$n2);
	        $t2=@temp2[0];
		if($t1 eq $t2)
			{
			print F"$n1\t$n2\n";
			}
		}
	}
close F;close FS1,close FS2;

eew
we
wewewewe


wdewd
we
we
wew
e
ee
we
we


