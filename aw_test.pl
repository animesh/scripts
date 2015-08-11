#!/usr/bin/perl 
# Create sine wave WAV files 
# Based on code found in Audio::WAV::Write POD 
use strict; 
use Audio::Wav; 
use Getopt::Std; 
#use Complex::Maths;
my %opts; getopts('?hb:f:H:s:t:V:z:', \%opts); 
if ($opts{h} || $opts{'?'}) { print usage(); 
	exit; 
	} 
my $outfile = $opts{f} || 'out.wav'; 
my $hertz = $opts{z} || 440; my $seconds = $opts{t} || 2; 
my $harmonics = $opts{H} || 1; my $sample_rate = $opts{s} || 44100; 
# CD quality; 
my $bits_sample = $opts{b} || 16; 
# 4,8,16 are all good choices 
my $volume_scalar = 1; 
if ($opts{V} < 1 && $opts{V} > 0) { $volume_scalar = $opts{V}; } 
my $wav = Audio::Wav->new; my $write = $wav->write($outfile, { bits_sample => $bits_sample, sample_rate => $sample_rate, channels => 1, } ); 
my $pi = 22/7; 
# close enough; 
my $len = $seconds * $sample_rate; 
my $max_no = (2 ** $bits_sample) / 2 * $volume_scalar; 
# split Harmonics value into an array 
$harmonics = [ split /\s*,\s*/, $harmonics ]; 
my $next = 0; for my $pos (0..$len) { my $hz = $hertz; 
# throw in some harmonics, but keep the tonic dominate 
if ($pos % 2 == 1) 
	{ $hz *= $harmonics->[$next++]; } 
	$next = 0 if $next >= @{$harmonics}; 
my $time = ($pos/$sample_rate) * $hz; $write->write( sin($pi * $time) * $max_no ); } 
$write->finish; 

#sub usage { 
#	return 
#		< bit resolution (defaults to 16-bit) f name of the outfile (defaults to 'out.wav') H Add this harmonic to the base tone. Can be a comma-separated list. s sample rate (defaults to 44100 (CD quality)) t number of seconds to make the file (default is 2) V Volume multiplier (decimal values cut the default MAX volume) z Frequency in hertz of the WAV file (default is 440) EOT 
#}
