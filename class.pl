#!/perl/user/bin/perl



print "Enter the list of file names\n[ALL FILE NAMES SHOULD BE IN A SINGLE COLUMN\n";

$list = <>;
chomp($list);

open (IN, "$list")|| die "can`t open $!";

while ($line = <IN>)
	{
	chomp($line);
	print "$line\n";
	push (@files, $line);
	}

open (OP, ">$list.csv");
print OP "##CLASS##\t  ##FOLD##\t  ##SUPERFAMILY##\t  ##FAMILY##\n";
for ($i=0; $i<= $#files; $i++)
	{
	$name = $files[$i];
	print "name= $name\n";
	print OP "\nGene file name=$name\n";

	mainprog($name);
	}


sub mainprog {

		$class = 'unknown';
		$fold = 'unknown';
		$supfam='unknown';
		$fam ='unknown';
		$in = $_[0];
		print "in=$in\n";
		open (F, "$in");
		#open (O, ">$in.csv");
		while ($ll = <F>)
			{
			#print "ll= $ll\n";
			if ($ll =~ /Class:/)
				{
				print "ll=$ll\n";
				$ll =~ s/Class://;
				$ll =~ s/\s+//g;
				$class = $ll;
				print OP "$class\t";
				}
			elsif ($ll =~ /Fold:/)
				{
				print "ll=$ll\n";
				$ll =~ s/Fold://;
				$ll =~ s/\s+//g;
				$fold = $ll;
				print OP "$fold\t";
				}
			elsif ($ll =~ /Superfamily:/)
				{
				print "ll=$ll\n";
				$ll =~ s/Superfamily://;
				$ll =~ s/\s+//g;
				$supfam = $ll;
				print OP "$supfam\t";
				}
			elsif ($ll =~ /Family:/)
				{
				print "ll=$ll\n";
				$ll =~ s/Family://;
				$ll =~ s/\s+//g;
				$fam = $ll;
				print OP "$fam\t";
				}

			}
			print OP "\n";
	}#ends subroutine


