#!/usr/bin/perl
#system("ls -1 vol.*.txt | wc > $size");
$size = `ls -1 vol.*.txt | wc`;
split(/\s+/,$size);$size=$_[1];
if($size<1){die"Size NULL\n";}
print "$size\n";
open(FO,">volall.out");
open(FOF,">ftr.out");

for($c=0;$c<$size;$c++){
	$cnt=$c+1;
	$file="vol.".$cnt.".txt";
	print "Processing $c\t$file\n"; 
	open(F,"$file");
	while($line=<F>){
		chomp $line;
		@tmp=split(/\,/,$line);
		$row++;
		$col=@tmp;
		print "Row $row has $col Columns @tmp[-1]\n";
		print FOF"Row $row has $col Columns @tmp[-1]\n";
                if($row==1){  
		  for($cc=0;$cc<($col-1);$cc++){
			$colnumm=$cc+1;
			$ftrname="FTR.$colnumm";
                          print FO"$ftrname,";
                  }
		  print FO"CLASS\n";
		}
		for($cc=0;$cc<($col-1);$cc++){
			print FO"@tmp[$cc],";
		}
		if(@tmp[-1]==1){print FO"C1\n";}
		elsif(@tmp[-1]==0){print FO"C0\n";}
	}
	$row=0;
}

