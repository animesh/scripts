#!/usr/bin/perl
# creatertf.pl - Quintiles Clinical Search


use CGI qw(:standard escapeHTML);
use Qui::QuiDB; 	#for database connection
use warnings;
use RTF::Writer;

my ($query) = new CGI;
my ($dbh) = Qui::QuiDB::connect();
my ($filepath) = Qui::QuiDB::get_file_path ();			#returns file path with IP where pl files are kept
my ($JSCRIPT) = Qui::QuiDB::jscript();				#calling for javascript fuctionality /usr/lib/perl5/5.8.0/Qui/QuiDB.pm
my ($styl) = {-style => 'font-family: arial;font-size: 12'};
my ($jspath) = Qui::QuiDB::get_js_path ();			#returns file path with IP where js files are kept
my ($cookieuid) = cookie('uid'); #added for handling sessions/cookies


###
$cookieuid="admin";

#my $templatepath="d:/perl";
#my $templatepath="/var/www/html/upload";
my $templatepath="/var/www/html/template";

#$templatepath="c:/perl";

#############Excel####################
use Spreadsheet::ParseExcel::SaveParser;
########################################
#@ MAIN_PROGRAM
	print header ();
  	my @selsmids=param("fs");
        my $cnt=0;
        my ($date,$hid,$country,$hospital,$drid,$firstname,$lastname,$title,$chinesename,$faxno,$indication);
        my ($frvdate,$postalcode,$state_or_province,$address);
	my @string1,@string2;
        my ($sec,$min,$hour,$mday,$mon,$year,
          $wday,$yday,$isdst) = localtime time;
        $mon=$mon+1;
        $year=$year + 1900;
        $date="$mday/$mon/$year";

        my $end="\\par }}";

	my $fid=Qui::QuiDB::collapse_whitespace(Qui::QuiDB::trim(param("fid")));

	foreach $smid (@selsmids)
	{

		if ($cnt==0)
		{
			my $mypath1;

			$rtfname = sprintf("rtf%i%i.rtf", time, $$);
                        `touch /var/www/html/output/$rtfname`;
                        `chmod 777 /var/www/html/output/$rtfname`;

                        $mypath1 = "/var/www/html/output/$rtfname";


			open(MYOUTFILE, ">$mypath1");  #open for write, overwrite
		}

		$hid=Qui::QuiDB::collapse_whitespace(Qui::QuiDB::trim(param("$smid+hid")));
		$country=Qui::QuiDB::collapse_whitespace(Qui::QuiDB::trim(param("$smid+country")));
###########################################
		if (!defined $country)
		{
			$country ="";
		}
		$tempdfrecd=param("$smid+dfrecd");
		if (!defined $tempdfrecd)
		{
			$tempdfrecd ="";
		}
		$frvdate=Qui::QuiDB::collapse_whitespace(Qui::QuiDB::trim($tempdfrecd));

		if (!defined $frvdate)
		{
			$frvdate ="";
		}
		
		$drid=Qui::QuiDB::collapse_whitespace(Qui::QuiDB::trim(param("$smid+drid")));



		$sth3 = $dbh->prepare("select fname, lname,title,chname from drmast where drid = ?");
		$sth3->execute ($drid);
		if ($flnameref = $sth3->fetchrow_hashref())
		{
			$firstname=$flnameref->{fname};
			if (!defined $firstname)
			{
				$firstname ="";
			}
			$lastname=$flnameref->{lname};
			if (!defined $lastname)
			{
				$lastname ="";
			}
			$title=$flnameref->{title};
			if (!defined $title || $title eq "")
			{
				$title ="Dr.";
			}
			$chinesename=$flnameref->{chname};
			if (!defined $chinesename)
			{
				$chinesename ="";
			}
		}
		else
		{
			$firstname="";
			$lastname="";
			$title="";
			$chinesename="";
		}
                $sth3->finish();

		$sth3 = $dbh->prepare("select name,stpro,pin,address from hsptlmast where hid = ?");
		$sth3->execute ($hid);
		if ($flnameref = $sth3->fetchrow_hashref())
		{
                	$state_or_province=$flnameref->{stpro};
                	if (!defined $state_or_province)
                	{
                		$state_or_province ="";
                	}
                	$postalcode=$flnameref->{pin};
                	if (!defined $postalcode)
                	{
                		$postalcode ="";
                	}
                	$address=$flnameref->{address};
                	if (!defined $address)
                	{
                		$address ="";
                	}
                	$address=~ s/\n/{\\line}/g;
			
			$hospital=$flnameref->{name};
			if (!defined $hospital)
			{
				$hospital ="";
			}
		}
		else
		{
                	$state_or_province="";
                	$postalcode="";
                	$address="";
                	$hospital="";
		}
                $sth3->finish();
                
                
		$faxno=return_a_field($dbh,"select fax from drmast where drid='$drid'");
		if (!defined $faxno)
		{
			$faxno ="";
		}


		$Ininameval=param("iname");
		if (!defined $Ininameval)
		{
			$Ininameval ="";
		}
		$indication=Qui::QuiDB::collapse_whitespace(Qui::QuiDB::trim($Ininameval));
		if (!defined $indication)
		{
			$indication ="";
		}

        	create_RTF();

		foreach $line(@string1)
		{
			push(@string2,$line);
		}

	       	if ($cnt == $#selsmids)
        	{
			foreach $line(@string2)
			{
				print MYOUTFILE $line;
			}
			print MYOUTFILE $end;
			close(MYOUTFILE);
        	}

		$cnt++;

           }

########

	$disppath=$jspath."output/".$rtfname;
	
	print $query->start_form(-action => url (), -name => "frm");
	print "<script language='javascript' type='text/javascript'>";
	print "   <!--
	     Newsite= window.open('$disppath','_self','width=970,height=550,top=10,resizable=1,scrollbars=1,menubar=1');
	     // -->";
	 print "</script>";
	print $query->end_form();



#######





exit (0);
#@ MAIN_PROGRAM



sub create_RTF
{
my @string=getFile(param("typ"));

@string1=();

if ($cnt >0){ push(@string1, "{\\page}" );}

foreach $line (@string)
{
	$line =~ s/<TT>/$title/;
	$line =~ s/<FN>/$firstname/;
	$line =~ s/<LN>/$lastname/;
	$line =~ s/<CGN>/$chinesename/;
	$line =~ s/<CY>/$country/;
	$line =~ s/<HN>/$hospital/;
	$line =~ s/<TY>/$date/;
        $line =~ s/<IND>/$indication/;
        $line =~ s/<FX>/$faxno/;
        $line =~ s/<FID>/$fid/;
        $line =~ s/<AD>/$address/;
        $line =~ s/<SP>/$state_or_province/;
        $line =~ s/<PC>/$postalcode/;
        $line =~ s/<FRD>/$frvdate/;

#        print "writing line\n";
        push(@string1,$line);

}


}



sub getFile
{
my $typ=shift;

#print "type=$typ";

if ($typ eq "1")
{
	$fname="$templatepath/ThankYou";
}
elsif ($typ eq "2")
{
	$fname="$templatepath/SuccessfullBid";
}
elsif ($typ eq "3")
{
	$fname="$templatepath/UnsuccessfullBid";
}
else
{
	return "";
}


if ($cnt > 0) { $fname .= "1"; }

#print "opening file $fname for type $typ";

open(MYINPUTFILE, $fname); # open for input
my(@lines) = <MYINPUTFILE>;         # read file into list
close(MYINPUTFILE);
return @lines;
}



sub get_disp_date
{
	my $paramdate = shift;
	my $calcdate;
	if(defined $paramdate and $paramdate ne "")
	{
		my @date=split(/-/,$paramdate);
		if ($#date ==2)
		{
			$calcdate=$date[2]."/".$date[1]."/".$date[0];
			
		}
		else
		{
			$calcdate="00/00/0000";
			
		}
	}
	else
	{
		$calcdate="00/00/0000";
		
	}
	return ($calcdate);
}


#sub get_db_date
#{
#	my $calcdate1;
#	my $paramdate1 = shift;
#	if (defined $paramdate1 and $paramdate1 ne "")
#	{
#		my @date1=split(/\//,$paramdate1);
#		if ($#date1 ==2)
#		{
#			$calcdate1=$date1[2]."-".$date1[1]."-".$date1[0];
#		}
#		else
#		{
#			$calcdate1="0000-00-00";
#		}
#	}
#	else
#	{
#		$calcdate1="0000-00-00";
#	}
#
#	return ($calcdate1);
#}

sub return_a_field
{
	my($dbh, $query) = @_;
	my($sth);
	my($val);
	$sth = $dbh->prepare ($query) or die "Error";
	$sth->execute ();
	if($sth->rows() == 0)
	{
		$sth->finish();
		return;
	}
	else
	{
		my @row = $sth->fetchrow_array ();
		return ($row[0]);
	}
	$sth->finish ();
}
