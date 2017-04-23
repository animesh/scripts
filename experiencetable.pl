#!/usr/bin/perl
# clinicalsearch.pl - Quintiles Clinical Search


use CGI qw(:standard escapeHTML);
use Qui::QuiDB; 	#for database connection
use warnings;

my ($query) = new CGI;
my ($dbh) = Qui::QuiDB::connect();
my ($filepath) = Qui::QuiDB::get_file_path ();			#returns file path with IP where pl files are kept
my ($JSCRIPT) = Qui::QuiDB::jscript();				#calling for javascript fuctionality /usr/lib/perl5/5.8.0/Qui/QuiDB.pm
my ($styl) = {-style => 'font-family: arial;font-size: 12'};
my ($jspath) = Qui::QuiDB::get_js_path ();			#returns file path with IP where js files are kept
my ($globalflag) = "false";
my ($flagqp) = "false";
my ($flagta) = "false";
my ($cookieuid) = cookie('uid'); #added for handling sessions/cookies
my ($rflag, $wflag, $mflag, $eflag);


###
#$cookieuid="admin";

#############Excel####################
use Spreadsheet::ParseExcel::SaveParser;
#my $CSV_SCHEMA = "csv";
#my $SCHEMA_FILE = "test.xls";
#my $TAB = "\t";
#my $NEWLINE = "\n";
#my $CSV_SEPARATOR = " ";
#open(FILE , ">/var/www/html/test.xls") or die($!);#Excel
#$SCHEMA_FILE .= ".xls"; #Excel
########################################
#@ MAIN_PROGRAM
	print header ();

	##Added for menu###########################

	print "<style>\n";
	print "a:hover{color:ff0033}\n";
	print "a{text-decoration:none;}\n";
	print "</style>\n";
	
	print "<script>";
	print "function errormsg(){";
	print "alert('Yes');";
	print "}";
	print "</script>";

	###########################################

	my $qcookie="SELECT exptable FROM modulerights WHERE uid='$cookieuid' ";
			 $sthcook=$dbh->prepare($qcookie);$sthcook->execute();
			 while (my $ref =$sthcook->fetchrow_hashref())
			 {
			 	$exptable=$ref->{exptable};
			 }

	print start_html (-title => "Hospital Repository Search", -bgcolor => "#FFF8DF", -onload=>"if('$exptable' != 'Y'){alert('You do not have sufficient access right to create experience table')}" ,-script => $JSCRIPT );

	##Added for menu###########################


	print "<script type='text/javascript'>\n";
	print "function Go(){return}</script>\n";
	print "<script type='text/javascript' src='".$jspath."exmplmenu_var.js'></script>\n";
	print "<script type='text/javascript' src='".$jspath."menu_com.js'></script>\n";
	print "<TABLE cellSpacing=0 cellPadding=0 width=\"100%\" border=0>\n";
	print "<TR>\n";
    	print "<TD><img src='".$jspath."logo.jpg'>\n";
	print "</TD>\n";
	print "</TR>\n";
	print "</TABLE>\n";

	##########Checking for the user in the cookie. Cookie will be available if the user is properly login############
#	if (length($cookieuid) == 0) {
#		$spc = "&nbsp" x 50;
#		my ($styls) = {-style => 'font-family: arial;font-size: 18;color: red'};
#		print br ();print br ();print br ();
#		print $query->Tr ({-width => "100%"},
#			td({-bgcolor => "#02BEA2", -width => "100%"}, $spc, span($styls, strong("Access is restricted to authorised persons! Login to access this screen"))
#			));
#		exit (0);
#	}
#	##################################################################################################################
#
#	#########Getting user rights based on cookies ####################################################################
#
#	#print p ("cookieuid : ", $cookieuid);
#	$sthrights = $dbh->prepare("select * from modulerights where uid = ? and mname = 'CLINICAL'");
#	$sthrights->execute($cookieuid);
#	if ($sthrights->rows() != 0){
#		$sthrightsref = $sthrights->fetchrow_hashref();
#		$rflag = $sthrightsref->{rpermission};
#		$wflag = $sthrightsref->{wpermission};
#		$mflag = $sthrightsref->{mpermission};
#		$eflag = $sthrightsref->{epermission};
#	} else {
#		$spc = "&nbsp" x 50;
#		my ($styls) = {-style => 'font-family: arial;font-size: 18;color: red'};
#		print br ();print br ();print br ();
#		print $query->Tr ({-width => "100%"},
#			td({-bgcolor => "#02BEA2", -width => "100%"}, $spc, span($styls, strong("Access is restricted to authorised persons! Login to access this screen"))
#			));
#		exit (0);
#	}
#
#	##################################################################################################################
#
#	###########Checking for user permissions##########################################################################
#
#	if (lc($rflag) eq 'n') {
#		$spc = "&nbsp" x 50;
#		my ($styls) = {-style => 'font-family: arial;font-size: 18;color: red'};
#		print br ();print br ();print br ();
#		print $query->start_form(-name => 'frm');
#		print $query->Tr ({-width => "100%"},
#			td({-bgcolor => "#02BEA2", -width => "100%"}, $spc, span($styls, strong("Access is restricted for this user : $cookieuid!"))
#			));
#		print $query->end_form();
#		exit (0);
#	}

	##################################################################################################################
	if ($exptable ne "Y")
	{
			print $query->start_form (-action => url (),-name=>"frm" );	
#			print "<CENTER><h4  style='color: red;font-size:18;font-family:arial'>You are not authorized to carry out this operation</h4></CENTER>";	
			print $query->end_form();
			exit(0);

	}

       	create_excel_table();


exit (0);
#@ MAIN_PROGRAM





sub create_excel_table
{
	my @newcol_list = ("Therapeutic Area","No. of Clinical Project","Phase","# of patients","Total # of sites","Number of Sites Per Country" );

	my $oEx = new Spreadsheet::ParseExcel::SaveParser;
	my $oBook = $oEx->Create();
	my $iF = $oBook->AddFont
	(
		Name  => 'Arial',
        	Height    => 8,
        	  	
        	Underline => 0,
        	Strikeout => 0,
        	Super     => 0,
	);
	my $iF1 = $oBook->AddFont
	(
		Name  => 'Arial',
        	Height    => 8,
        	Bold      => 1, #Bold
        	Underline => 0,
        	Strikeout => 0,
        	Super     => 0,
	);

	my $iFmt =
	$oBook->AddFormat
	(
        	Font => $oBook->{Font}[$iF1],
        	Fill => [1, 55,0],         # Filled with gray
                                    	# cf. ParseExcel (@aColor)
                
#        	BdrStyle => [0, 1, 1, 0],   #Border Right, Top
#        	BdrColor => [0, 11, 0, 0],  # Right->Green
        	Wrap => 0,
        	Hidden => 0,
        	Lock => 0,
        	
        	
        	
	);

        my $iFmt1 =
	$oBook->AddFormat
	(
        	Font => $oBook->{Font}[$iF],
        	Wrap => 0,
        	Hidden => 0,
        	Lock => 0
	);

	$oBook->AddWorksheet('NewWS');

	my($cellRow) = 0;
	my($cellCol) = 0;

	#print "======cnt=$#newcol_list";

	foreach $xx (@newcol_list)
	{
  		$oBook->AddCell(0, $cellRow, $cellCol, $xx, $iFmt);
  		$cellCol++;
	}

        my $cstart=$cellCol--;


        my @tids=return_field($dbh,"select distinct tid from cstudy");
	my @countries=return_field($dbh,"select distinct a.country from hsptlmast a ,smetrics b  where  a.hid=b.hid");

	$cellRow=1;
        foreach $xx (@countries)
	{
  		$oBook->AddCell(0, $cellRow, $cellCol, $xx, $iFmt);
  		$cellCol++;
	}


        $cellRow=2;$cellCol=0;

        my ($aa,@arr);
	foreach $xx (@tids)
	{
		$cellCol=0;

                $val=return_a_field($dbh,"select tname from tmaster where tid='$xx'");
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt1 );
		$cellCol++;
		
                $val=return_a_field($dbh,"select count(pid) from cstudy where tid='$xx'");
                if ($val == 0){ $val ="" ;}
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt1 );
		$cellCol++;

                @arr=return_field($dbh,"select distinct phase from cstudy where tid='$xx' order by phase");
                
                $val=join (" , ", @arr) if @arr;
                
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt1 );
		$cellCol++;

                $val=return_a_field($dbh,"select sum(npractual) from pmetrics p,cstudy c where c.pmid=p.pmid and c.tid='$xx'");
                if ($val == 0 or $val == 0.000){ $val ="" ;}
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt1 );
		$cellCol++;

		$val=return_a_field($dbh,"select count(hid) from smetrics s,cstudy c where c.tid='$xx' and s.pid=c.pid");
                if ($val == 0){ $val ="" ;}
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt1 );
		$cellCol++;

		foreach $aa (@countries)
		{
			$val=return_a_field($dbh,"select count(a.hid) from hsptlmast a ,smetrics b,cstudy c  where  a.hid=b.hid and b.pid=c.pid and c.tid='$xx' and a.country='$aa'");
			if ($val == 0 or $val == 0.000){ $val ="" ;}
			$oBook->AddCell(0, $cellRow, $cellCol,$val , $iFmt1);
			$cellCol++;
	        }

                $cellRow++;

	}


		$cellRow++;
		$cellCol=1;
		
                $val=return_a_field($dbh,"select count(pid) from cstudy");
                if ($val == 0){ $val ="" ;}
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt );
		$cellCol++;

                @arr=return_field($dbh,"select distinct phase from cstudy where phase !='' order by phase");
                $val=join (" , ", @arr) if @arr;
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt );
		$cellCol++;
		
                $val=return_a_field($dbh,"select sum(npractual) from pmetrics p,cstudy c where c.pmid=p.pmid ");
                if ($val == 0 or $val == 0.000){ $val ="" ;}
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt );
		$cellCol++;
		
		$val=return_a_field($dbh,"select count(hid) from smetrics s,cstudy c where s.pid=c.pid");
		if ($val == 0 or $val == 0.000){ $val ="" ;}
                $oBook->AddCell(0, $cellRow, $cellCol, $val,$iFmt );
		$cellCol++;

		foreach $aa (@countries)
		{
			$val=return_a_field($dbh,"select count(a.hid) from hsptlmast a ,smetrics b,cstudy c  where  a.hid=b.hid and b.pid=c.pid  and a.country='$aa'");
			if ($val == 0 or $val == 0.000){ $val ="" ;}
			$oBook->AddCell(0, $cellRow, $cellCol, $val, $iFmt);
			$cellCol++;
	        }

	my $mypath1;
	
	$thexcelname = sprintf("thexcel%i%i.xls", time, $$);
	`touch /var/www/html/output/$thexcelname`;
	`chmod 777 /var/www/html/output/$thexcelname`;


	$mypath1 = "/var/www/html/output/$thexcelname";

#	$mypath1 = "d:/perl/experience.xls";
	$disppath=$jspath."output/".$thexcelname;

	$oEx->SaveAs($oBook, $mypath1);




	#$disppath=$jspath."output/experience.xls";

#	$disppath=$jspath."experience.xls";

#-onClick=>"javascript:window.open('$tempvar','_self','_refresh')
#	$meta = {-http_equiv=>'refresh', -content=>'0;url='.$disppath};
#	print $query->start_html(-name => 'frm' ,-bgcolor => "#FFF8DF", -title=>'Doctor database -Hospital Serach  ', -script => $JSCRIPT, -head=>meta($meta));
print $query->start_form(-action => url (), -name => "frm");
print "<script language='javascript' type='text/javascript'>";
print "   <!--
     Newsite= window.open('$disppath','newsite','width=970,height=550,left=10,resizable=1,scrollbars=1,menubar=1');
     // -->";
 print "</script>";
print $query->end_form();

#print $query->start_form(-name=>"frm");
#print $query->end_form;
}
#@ CREATE_EXPERIENCE_TABLE



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

sub return_field
{

	my($dbh, $query) = @_;
	my($sth);
	my(@val);
	$sth = $dbh->prepare ($query) or die "Error";
	$sth->execute ();
	if($sth->rows() == 0)
	{
		$sth->finish();
		return ("");
		exit;
	} else
	{
		while (my @row = $sth->fetchrow_array ())
		{
			push (@val, $row[0]);
		}
	}
	$sth->finish ();
     if( @val)
     {
	return (@val);
	}
      else
      {
	return "";
	}
}
