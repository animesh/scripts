##
#     C O N F I G . P L
#
# configuration directives for mysqler's archive program
# Please edit this file to reflect your site configuration
##

#
# Your system's URL cgi path
#
$CFG::CgiPrefix = "/cgi-bin/";

#
# and where it actually resides on the system
#
$CFG::CgiDN = "/usr/local/apache/sites/stefano/cgi-bin";

#
# The systems directory where archiver roots its system's report
# directories
#   eg: /usr/local/apache/site/htdocs is the root for
#          /usr/local/apache/htdocs/myserver1.mycompany.com/
#          /usr/local/apache/htdocs/myserver2.mycompany.com/
#
$CFG::ArchiverDN = "/usr/local/apache/sites/stefano/htdocs";

#
# Your HTML document root directory. It can be the same as $CFG::ArchiverDN
#
$CFG::HtdocRootDN = "/usr/local/apache/sites/stefano/htdocs";
