         use SOAP::Lite;
         print SOAP::Lite
           -> uri('http://www.soaplite.com/Temperatures')
           -> proxy('http://services.soaplite.com/temper.cgi')
           -> f2c(32)
           -> result;

