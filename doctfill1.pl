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

#!/usr/bin/perl
use DBI;
$t1=times();
$host_name = "localhost";
$db_name = "DDB";
$user = "root";
$password = "infosys";
$dsn = "DBI:mysql:host=$host_name;database=$db_name;user=$user;password=$password;";
$dbh=DBI->connect ($dsn, {PrintError => 0, RaiseError => 1});
@country=qw/singapore thailand china hongkong malaysia taiwan phillipines/;$lcont=@country;
@gender=qw/m f/;
#Connect stuff up here
#drmast="drmast";
$insert_check=$dbh->prepare('insert into drmast(drid,fname,lname,title,tel,fax,cellno,email,aname,atel,afax,rinst,cexpdt,moddate,stpro,country,gender,remarks,chname,ext,assoname,aext) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)') or die("Couldn't prepare test insert".$dbh->errstr());
@array=( 'a'..'z' );$length=@array;$counter=20000;
foreach(1..$counter){
	$drid="DR".$contrand.$_;$aname=$drid;
	$col4 .= @array[int(rand($length))-1] foreach(1..int(rand(8)));
	$fname= "Dr.".$col4;
	$lname= $col4.".lastname";
	$title= "Dr.".$lname.".".$contrand;
	$gender=@gender[int(rand(2))-1];
	$country=@country[int(rand($lcont))-1];
	$contrand=substr($country,0,2);
	$tel=int(rand($counter));$fax=int(rand($counter));$cellno=int(rand($counter));$atel=int(rand($counter));
	$rinst=$tel;$moddate=times();$stpro=$contrand,
	$remarks .= @array[int(rand($length))-1] foreach(1..int(rand(8)));
	$email=$drid."\@".$remarks.".com";
	$chname=$remarks;$ext=$tel;$assoname=$remarks;$aext=$tel;
	$insert_check->execute($drid,$fname,$lname,$title,$tel,$fax,$cellno,$email,$aname,$atel,$afax,$rinst,$cexpdt,$moddate,$stpro,$country,$gender,$remarks,$chname,$ext,$assoname,$aext) or die("Couldn't do insert!!".$dbh->errstr()); 
}
$insert_check->finish();
#$dbh->disconnect();
$t2=times();
$tt=($t2-$t1)/(24*60);
print "Total time taken by the script : $tt\n\n";
$query = $dbh->prepare('select * from drmast');
$query->execute();
if($query->rows() == 0) {
                print ("");
                $query->finish();
                return ("--No records found--");
                exit;
        } else {
                while (@row = $query->fetchrow_array ())
                {
                print "@row\n";
                #push (@val, @row);
                }
        }
        $query->finish ();
#for ($c=0;$c<=$#val;$c++){print "\t@val[$c]\n";}
$dbh->disconnect();
