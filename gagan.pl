$masterDir = $ARGV[0];

opendir(Dir, $masterDir) or die "cannot open directory $masterDir";

@masterDirArray = grep {/\.TXT$/i} readdir(Dir);
rewinddir(DIR);
	open OUTFILE, ">", "call.txt";

   foreach $indirname (@masterDirArray) {

  	open INFILE, "<", "$masterDir\\$indirname";

	$indirname =~ s/\.TXT$//i;

	@form=split(/\_/,$indirname);

	$date=substr($form[2],0,2)."-".substr($form[2],2,2)."-".substr($form[2],4,4);

	print $indirname;

  	while ($theLine=<INFILE>) {

		$theLine=~s/\|/\t/g;

   	  print OUTFILE $form[1]."\t".$date."\t".$theLine;

 	}

 	close INFILE;

	}

	close OUTFILE;