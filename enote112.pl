#!/usr/bin/perl
#
#  Electronic notebook stub.
#
#  This is a minimal stub for the electronic notebook, that sets configuration
#  variables for one or more electronic notebooks.  Also, since this stub is
#  the only notebook component directly referenced by a Web browser, it makes
#  it possible to set up different access restrictions for different notebooks,
#  simply by restricting Web access to this stub or its directory.
#
#  The remaining notebook routines are contained in the file 'enotelib.pl',
#  which is set up to be shared by all the notebook stubs.  The shared notebook
#  library does not need to be placed in a directory visible to Web browsers,
#  it just needs to be visible to the Web server (and the user name and group
#  that the Web server runs under).
#
#  Copyright (C) 1996-2003  Oak Ridge National Laboratory
#
#  Al Geist 
#  Noel M. Nachtigal
#  David Jung
#
#
#  version 1.12
#    Added pjpeg, x-png to image upload types to match what web servers send them as.
#    Added subscription service and daily notification feature of changed pages
#    Added printing all or set of pages
#    Improved search function to always search author, title, date, keywords
#    Removed java applet sketchpad due to interface problems with new browsers
#    Added many new MIME types including PDF, MS office, postscript
#
#  Version 1.11
#    Added last modified dates to Contents page
#    Extended configuration to allow notarize to be turned off
#    Added addendums to change history 
#    Improved Table of contents layout
#    Changed default background to improve readability
#    Added <enote:showtags> feature that allows pages to display XML or 
#      HTML examples rather than trying to execute them.
#    Minor bug fixes
#
#  Version 1.10
#    Integrated sketchpad into "ADD", "EDIT", and "ANNOTATE" functions
#    Modified TOC to return hidden objects in notebook
#    Integrated an external control panel for buttons
#    Implemented "ANNOTATE" function
#    Implemented "NOTARIZE" function to freeze page to change
#    Extended configuration to allow read-only access
#    Made change history a pull down menu to conserve page space
#    Replaced line horizontal with line reload hint
#
#  Version 1.09
#    Bug fixes, no new features.
#
#  Version 1.08
#    Added fancy Javascript bells to the navigation bar buttons.
#    The notebook name is now passed as a regular CGI parameter, instead of
#      being appended to the URL as further path.
#    The notebook script's URL is now built dynamically, to accomodate servers
#      with changing host names (e.g., laptops).
#
#  Version 1.07
#    Added edits history, which changes the file format (backwards compatible).
#
#  Version 1.06
#    Added 'Edit' and 'Delete'.
#    Added edits history to page.
#    Added empty stubs for 'Annotate' and 'Notarize'.
#    Changed the 'Table of Contents' to numbered list.
#    New set of buttons.
#
#  Version 1.05
#    Added uploading of files.
#    Added support for multiple MIME types.
#    Changed the naming convention for data files.
#    Removed the "<p>" and "</p>" surrounding entries in the text files.
#
#  Version 1.04
#    Added support for deleted pages or objects.
#    Cleaned up and reorganized the code.
#
#  Version 1.03
#    Added support for multiple notebooks that use the same stub.
#    Highlight required information on "Add" page (Tim Strayer).
#    Display page title with the page (Tim Strayer).
#
#  Version 1.02
#    Broke up the notebook script into a stub and a shared library.
#    Moved the notebook support images into the configurable section.
#
#  Version 1.01
#    Added image dimensions for the horizontal bar.
#
#  Version 1.0
#    Initial release.
#
###############################################################################

use strict;

###############################################################################
#
#  Section 1: Notebooks names, directories, and titles
#  Notebooks names, directories, and titles
#
#  The notebook stub can support multiple notebooks, all of which would share
#  the same access restrictions and layout features.  Individual notebooks are
#  identified by a parameter that is appended to the URL for this stub; for
#  example, if this notebook stub is located at
#    http://www.someserver.net/cgi-bin/notebook.cgi
#  then the URL of a notebook named 'mynotebook' would be
#    http://www.someserver.net/cgi-bin/notebook.cgi?nb=mynotebook
#
#  For each notebook, specify here the directory where its entries will be put,
#  and its title.  Notebook names must be made up of only lowercase letters and
#  digits. Displayed is an example of a two notebook configuration.
#
#  The "$main::nb" is the default notebook. (Used when nb= is not specified)
#
###############################################################################

$main::notebook{'notebook'} = {(
  'dir'   => 'c:/httpd/root/enote1.12/html/notebook/',
  'title' => "Project Notebook",
  )};

# Example of how to specify additional notebooks
$main::notebook{'data'} = {(
  'dir'   => 'c:/httpd/root/enote1.12/html/instrument/',
  'title' => "Raw Instrument Data Notebook"
  )};

$main::nb = 'notebook';

#  Subscription database file - must be absolute path and
#  accessible by all notebooks (that support subscription)
$main::subscription = 'c:/httpd/root/enote1.12/html/subscriptions.ens';
$main::subscriptionReplyTo = 'E-Note <NoReturnAddress@nowhere.com>';

###############################################################################
#
#  Section 2: Recognized MIME types
#
#  Notebooks accept entries with a MIME type out of a given list of acceptable
#  MIME type; specify that list here. A sample list is shown below. 
#  The strings on the right are MIME types, and can be either widely 
#  accepted MIME types (such as 'text/plain' or 'image/gif') 
#  or MIME types developed specifically for a given notebook 
#  (such as 'application/x-ornl-notebook').  The string on the
#  left is displayed to the user, and thus should be a layman's description of
#  the MIME type on the right.
#
#  The "$main::def_type" is the default type presented to the user, and *must*
#  match a user description from the list (otherwise it will be ignored and a
#  random description from the list will be used instead).
#
###############################################################################

%main::mimetypes = (
  'Text, HTML'   => 'text/html',
  'Image, GIF'   => 'image/gif',
  'Image, JPEG'  => 'image/jpeg',
  'Image, BMP'   => 'image/bmp',
  'Image, PNG'   => 'image/png',
  'Text, plain'  => 'text/plain',
  'PDF'          => 'application/pdf',
  'PostScript'   => 'application/postscript',
  'MS Word'      => 'application/msword',
  'PowerPoint'   => 'application/vnd.ms-powerpoint',
  'Excel'        => 'application/vnd.ms-excel',
  );
$main::def_type = 'Text, plain';

###############################################################################
#
#  Section 3: General configuration flags and variables
#
###############################################################################

#  Set to 1 if flock() exists (server is Unix), to 0 otherwise (Windows/Mac).
$main::flock = 0;

#  Directory of the shared notebook library routines 'enotelib.pl'.
$main::libdir = 'c:/httpd/root/enote1.12/cgi-bin';

#  The relative URL for this configuration script.
$main::script = '/cgi-bin/enote112.pl';

#  The relative URL of the directory with the GIFs.
$main::gifs = '/enote1.12/html/gifs';

#  If 1, use the $main::sendmail command to send email (e.g. sendmail under UNIX).  
#  If 0, uses the Sendmail.pm package (which uses SMTP directly)
$main::useSendmailCommand = 0;

#  Program to use for sending e-mail (ignored unless $main::useSendmailCommand is 1)
$main::sendmail = '/usr/sbin/sendmail';

#  SMTP service host to use for outgoing email 
#  (ignored unless $main::useSendmailCommand is 0)
$main::SMTPHost = 'YourHostHere';


#  Whether users want a button bar on top of each page (nobar = 0)
#  or not draw the buttons (nobar = 1) (1 requires external Control Panel)
$main::nobar = 0;

#  Whether users wants the external control panel to appear (nopanel = 0)
#  or not appear (nopanel = 1) and just use button bar
$main::nopanel = 1;

#  Are users allowed to subscribe to e-mail change notifications for these notebooks?
#   (1=yes 0=no)
$main::subscribe = 1;

#  Display the email address of subscribers (1=yes, 0=no)
$main::showemails = 1;

# Print option available for individual pages? (1=yes, 0=no)
$main::printpage = 0;

# When printing show deleted pages in Contents and Printed output as "Deleted page", 
# or just omit them. (0=omit 1=show as 'Deleted page')
$main::showdeleted = 1;

################# Write Access to Notebook ###################################
#
#  Whether users are allowed to add Notebook pages  (noadd = 0)
#  or not allowed to add pages (noadd = 1)
$main::noadd = 0;

#  Whether users are allowed to delete Notebook pages  (nodelete = 0)
#  or not allowed to delete pages (nodelete = 1)
$main::nodelete = 0;

#  Whether users are allowed to edit Notebook pages  (noedit = 0)
#  or not allowed to edit pages (noedit = 1)
$main::noedit = 0;

#  Whether users are allowed to annotate Notebook pages  (noannotate = 0)
#  or not allowed to annotate pages (noannotate = 1)
$main::noannotate = 0;

#  Whether users are allowed to notarize Notebook pages  (nonotarize = 0)
#  or not allowed to notarize pages (nonotarize = 1)
$main::nonotarize = 0;


###############################################################################
#
#  Section 4: Notebook support images
#  These are common to all notebooks served by this stub.  To replace the
#  default buttons with a new set of buttons, replace the button GIFS with a
#  new set of GIFs (same names), and specify the new image sizes below.
#
###############################################################################

#  Horizontal line.
$main::linehorz  = '<center><img src="' . "$main::gifs/linehorz.gif" . 
                   '"></center>';

#  Horizontal line view page.
$main::lineview  = '<center><img src="' . "$main::gifs/linehorz.gif" . 
                   '"></center>';

#  Notebook page background.
$main::backgrnd = "$main::gifs/notebook.gif";

#  The height of the buttons (all are same height).
$main::btn_ht = 24;

#  The width of the "Add Page" button.
$main::add_wd = 36;

#  The width of the "Annotate" button.
$main::anno_wd = 70;

#  The width of the "Delete" button.
$main::del_wd  = 50;

#  The width of the "Edit" button.
$main::edit_wd = 37;

#  The width of the "First" button.
$main::first_wd = 41;

#  The width of the "Last" button.
$main::last_wd = 39;

#  The width of the "Next" button.
$main::next_wd = 42;

#  The width of the "Notarize" button.
$main::notar_wd = 66;

#  The width of the "Previous" button.
$main::prev_wd = 67;

#  The width of the "Search" button.
$main::srch_wd = 57;

#  The width of the "Table of Contents" button.
$main::toc_wd  = 65;

#  The width of the "Print" button.
$main::print_wd = 38;

#  The width of the "Subscribe" button.
$main::subscribe_wd = 68;

#  The width of the "Unsubscribe" button.
$main::unsubscribe_wd = 84;

#  The width of the end buttons.
$main::lend_wd = 6;
$main::rend_wd = 4;

###############################################################################
#
#  Main starts here.
#
###############################################################################

#  Load the shared notebook library.
push @INC, $main::libdir;
require 'enotelib.pl';

&main();

exit 0;

__END__

