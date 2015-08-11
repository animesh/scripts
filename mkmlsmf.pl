#!/usr/bin/perl
# vim:ts=4 sw=4
#
# (c) Oliver Corff. Ulaanbaatar, Beijing, Berlin
#
# This file generates the set of Metafont top level files for
# the Mongol writing support. This generator can be used instead
# of copying the individual files.
#
# 2001-10-01
#
$Filename   ="";
#
@Languages  =(Mongol,Manju,'Mongol Glyph');
%glyph		=(	Mongol => Mongol,
				Manju => Manju,
				'Mongol Glyph' => 'Mongolian and all derived');
%Encoding   =(Manju => LMA,	Mongol => LMO,	'Mongol Glyph' => LMX);
%comment    =(Manju => '',	Mongol => '',	'Mongol Glyph' => '% ');
%tab	    =(Manju => '	',	Mongol => '	',	'Mongol Glyph' => '');
%Writing    =(Manju => Bithe,	Mongol => Bicig,	'Mongol Glyph' => Container);
%wrtng      =(Manju => bth,	Mongol => bcg, 'Mongol Glyph' => bxg);
%Abbr	    =(Manju => 'a',	Mongol => 'o', 'Mongol Glyph' => 'x');
@LRs	    =(Horizontal,Vertical);
%LRvalue    =(Horizontal => true,	Vertical => false);
%lrv	    =(Horizontal => 'h',	Vertical => 'v');
@Styles	    =(Wood,Steel);
%StyleValue =(Wood => wood,		Steel => steel);
%stv	    =(Wood => 'w',		Steel => 's');
@Weights    =(Medium,Bold);
%WeightValue=(Medium => 'm',	Bold => 'b');

sub redefined {
	$output = qq{%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        File: $Filename
%      Author: Oliver Corff and Dorjpalam Dorj
%        Date: October 1st, 2001
%     Version: 0.8
%   Copyright: Ulaanbaatar, Beijing, Berlin
%
% Description: Local $Language Script in Ligature Mode (Encoding: $Encoding{$Language})
%              $Language $Writing{$Language} $LR $Style $Weight Font Definition
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
font_identifier:=		"TeX $Language $Writing{$Language}";
font_coding_scheme:=		"$Encoding{$Language}";
input mbatoms.mf;		% Load Atoms
style:=$StyleValue{$Style};			% Defines titem and suul shapes, etc.
writing:=$Writing{$Language};$tab{$Language}		% Font: $Language $Writing{$Language}
LR:=$LRvalue{$LR};			% This is a $LR Font
input mbparm$WeightValue{$Weight}.mf;		% Load $Weight Weight Parameters
$comment{$Language}input mbcodes.mf;		% Load Common Encoding Vectors
input m$Abbr{$Language}codes.mf;		% Load $Language Encoding Vectors
$comment{$Language}input m$Abbr{$Language}ntrlig.mf;		% Load $Language Transliteration Ligatures
input mbpunc.mf;		% Oh yes, we build punctuation
input mbnums.mf;		% Oh yes, we build digits
input mbglyphs.mf;		% Oh yes, we build common glyphs
input m$Abbr{$Language}glyphs.mf;		% And we build $glyph{$Language} glyphs
end.}
}

for $Language (@Languages) {
	for $LR (@LRs) {
		for $Style (@Styles) {
			for $Weight (@Weights) {
				$Filename=	$wrtng{$Language}.
						$lrv{$LR}.
						$stv{$Style}.
						$WeightValue{$Weight}.
						".mf";
						
				print "$Filename: ";
				print "$Language\t-> $Writing{$Language} ";
				print "($Encoding{$Language}) ";
				print "$LR\t$Style$Weight\n";

				redefined;

				open(OUTPUT,">$Filename");
				print OUTPUT $output;
				close OUTPUT;
			}
		}
	}
}
