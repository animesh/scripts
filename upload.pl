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

#!/usr/bin/perl -w 

 use CGI; 

 $upload_dir = "D://tmp/"; 

 $query = new CGI; 

 $filename = $query->param("photo"); 
 $email_address = $query->param("email_address"); 
 $filename =~ s/.*[\/\\](.*)/$1/; 
 $upload_filehandle = $query->upload("photo"); 

 open UPLOADFILE, ">$upload_dir/$filename"; 

 binmode UPLOADFILE; 

 while ( <$upload_filehandle> ) 
 { 
   print UPLOADFILE; 
 } 

 close UPLOADFILE; 

 print $query->header ( ); 
 print <<END_HTML; 

 <HTML> 
 <HEAD> 
 <TITLE>Thanks!</TITLE> 
 </HEAD> 

 <BODY> 

 <P>Thanks for uploading your photo!</P> 
 <P>Your email address: $email_address</P> 
 <P>Your photo:</P> 
 <img src="$upload_dir/$filename" border="0"> 

 </HTML> 

END_HTML

EOF
