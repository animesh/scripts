#!/usr/bin/perl
##################

#get the current hit count from the
# counter file.
open(FILE, "counter.txt");
    $visits = <FILE>;
close(FILE);

# Incriment the hit count by 1
$visits++;

# Overwrite the old number with the new
# number which is 1 higher.
open(FILE, ">counter.txt");
    print FILE $visits;
close(FILE);

print "Content-type: text/html\n\n";
print "<html><body>";
if ($visits == 1000) {
    print "<font face='Arial,Verdana'>Congratulations, you are the 1000th visitor to this site!";
}
elsif ($visits == 1000000) {
    print "<font face='Arial,Verdana'>Whoa! You are the 1,000,000th visitor to this site!";
}
else {
    print "<font face='Arial,Verdana'>Bah, you are only the $visits visitor to this site...";
}
print "</body></html>";
exit;

To start off the script's execution, I simply did some opening, reading and writing of files to incriment the number of visitors to the site by one. Next is where the interesting part comes in, the program sends header information back to the browser stating "Hey HTML page is coming to you!" when it does the print "Content-type: text/html\n\n"; statement. After that all you really need to do is output HTML tags in print ""; commands. Here's another useful trick if you have a large block of HTML code where you don't need to do any PERL execution or condition statements in:

print <<"till_end_of_lines";
    <html><body>
        <font face="Verdana,Arial">Congratulations you are the $visits visitor to this site.
        <br><br>Thank you for visiting our site please be sure to drop us a line at our <a href="feedback.html">Feedback Page</a>!
    </body></html>
    till_end_of_lines