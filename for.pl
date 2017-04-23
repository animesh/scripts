#!/usr/bin/perl
$cont=4;
for ($c=0;$c<$cont;$c++) {
	for ($cc=0;$cc<$cont;$cc++) {
$ccc[$c][$cc]=$cc;
	}
}
for ($c=0;$c<$cont;$c++) {#print "\n";
	for ($cc=0;$cc<$cont;$cc++) {$min=$ccc[$c][$cc];
if($ccc[$c][$cc] ne 0){if ($ccc[$c][$cc]<$min) {
$min=$ccc[$c][$cc];
}
}
#print "$ccc[$c][$cc]\t";
	}
}
for ($c=0;$c<$cont;$c++) {print "\n";
	for ($cc=0;$cc<$cont;$cc++) {
print "$ccc[$c][$cc]\t";
	}
}
print $min;

