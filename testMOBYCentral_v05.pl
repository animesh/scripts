#!/usr/bin/perl -w
#use lib '/home/markw/BIO/moby-live/Perl';
#use lib '/home/markw/BIO/moby-live/Perl';
use MOBY::Central;

sub TEST {
    ($reg, $test, $expect) = @_;
    die "\a\a\aREG OBJECT MALFORMED" unless $reg =~/<success>(\d+)<\/success/;
    if ($1 == $expect){
        print "test $test\t\t[PASS]\n";
    } else {
        print "test $test\t\t[FAIL]\n$reg\n\n";
    }
}

my $m = q{
 <registerObjectClass>
	<objectType>TotalCrap</objectType>
	<Description><![CDATA[
			human readable description
			of data type]]>
	</Description>
	<Relationship relationshipType="ISA">
               <objectType articleName="SomeName">Object</objectType>
    </Relationship>
	<authURI>Your.URI.here</authURI>
	<contactEmail>You@your.address.com</contactEmail>
 </registerObjectClass>

};
#reg first object class 
TEST(MOBY::Central->registerObjectClass($m), 1, 1);
#reg duplicate object class
TEST(MOBY::Central->registerObjectClass($m), 2, 0);


$m = q{
 <registerObjectClass>
	<objectType>YetMoreCrap</objectType>
	<Description><![CDATA[
			human readable description
			of data type]]>
	</Description>
	<authURI>Your.URI.here</authURI>
	<contactEmail>You@your.address.com</contactEmail>
	<Clobber>0</Clobber>  
 </registerObjectClass>

};
#reg second object class
TEST(MOBY::Central->registerObjectClass($m), 3, 1);


$m=q{<registerServiceType>
         <serviceType>RetrieveCrap</serviceType>
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authURI>Your.URI.here</authURI>
         <Description>
           <![CDATA[ human description of service type here]]>
         </Description>
		 <Relationship relationshipType="isa">
			<serviceType>Retrieval</serviceType>
		 </Relationship>
         </registerServiceType>};
# register first service type
TEST(MOBY::Central->registerServiceType($m), 4, 1);
# register duplicate service type
TEST(MOBY::Central->registerServiceType($m), 5, 0);


$m=q{<registerNamespace>
           <namespaceType>Genbank:Crap</namespaceType>
           <contactEmail>your_name@contact.address.com</contactEmail>
           <authURI>Your.URI.here</authURI>
           <Description>
              <![CDATA[human readable description]]>
           </Description>
        </registerNamespace>};
# register first namespace
TEST(MOBY::Central->registerNamespace($m), 6, 1);
# register duplicate namespace
TEST(MOBY::Central->registerNamespace($m), 7, 0);



$m=q{      <registerService>
         <Category>moby</Category>
         <serviceName>MyCrappyService</serviceName>
         <serviceType>RetrieveCrap</serviceType>
         <authURI>your.URI.here</authURI>
         <URL>http://URL.to.your/Service.script</URL>;
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authoritativeService>1</authoritativeService>
         <Description><![CDATA[
               human readable COMPREHENSIVE description of your service]]>
         </Description>
         <Input>
            <Simple articleName="myname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
            <Collection articleName="myname">
                <Simple articleName="myname">
                    <objectType>TotalCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
                <Simple articleName="myname">
                    <objectType>YetMoreCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
            </Collection>
         </Input>
         <secondaryArticles>
            <Parameter articleName="limit_by">
               <datatype>INT</datatype>
               <default>10</default>
               <max>100</max>
               <min>1</min>
               <enum>1</enum>
               <enum>2</enum>
               <enum>10</enum>
               <enum>100</enum>
            </Parameter>
         </secondaryArticles>
         <Output>
            <Simple articleName="myoutputname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
         </Output>
      </registerService>};
# register first service (valid)
TEST(MOBY::Central->registerService($m), 8, 1);
# register duplicate service
TEST(MOBY::Central->registerService($m), 9, 0);



$m=q{<deregisterObjectClass>
  <objectType>TotalCrap</objectType>
</deregisterObjectClass>
};
# deregister object class with service dependencies
TEST(MOBY::Central->deregisterObjectClass($m), 10, 0);



$m=q{        <deregisterServiceType>
          <serviceType>RetrieveCrap</serviceType>
        </deregisterServiceType>
};
# deregister service type with dependencies
TEST(MOBY::Central->deregisterServiceType($m), 11, 0);




$m=q{<deregisterNamespace>
           <namespaceType>Genbank:Crap</namespaceType>
        </deregisterNamespace>};
# deregister Namespace with dependencies
TEST(MOBY::Central->deregisterNamespace($m), 12, 0);


$m=q{      <registerService>
         <Category>moby</Category>
         <serviceName>MyCrappyService</serviceName>
         <serviceType>RetrieveCrapFAIL</serviceType>
         <authURI>your.URI.here</authURI>
         <URL>http://URL.to.your/Service.script</URL>;
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authoritativeService>1</authoritativeService>
         <Description><![CDATA[
               human readable COMPREHENSIVE description of your service]]>
         </Description>
         <Input>
            <Simple articleName="myname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
            <Collection articleName="myname">
                <Simple articleName="myname">
                    <objectType>TotalCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
                <Simple articleName="myname">
                    <objectType>YetMoreCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
            </Collection>
         </Input>
         <secondaryArticles>
            <Parameter articleName="limit_by">
               <datatype>INT</datatype>
               <default>10</default>
               <max>100</max>
               <min>1</min>
               <enum>1</enum>
               <enum>2</enum>
               <enum>10</enum>
               <enum>100</enum>
            </Parameter>
         </secondaryArticles>
         <Output>
            <Simple articleName="myoutputname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
         </Output>
      </registerService>};
# register service with invalid service type
TEST(MOBY::Central->registerService($m), 13, 0);





$m=q{      <registerService>
         <Category>moby</Category>
         <serviceName>MyCrappyService</serviceName>
         <serviceType>RetrieveCrap</serviceType>
         <authURI>your.URI.here</authURI>
         <URL>http://URL.to.your/Service.script</URL>;
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authoritativeService>1</authoritativeService>
         <Description><![CDATA[
               human readable COMPREHENSIVE description of your service]]>
         </Description>
         <Input>
            <Simple articleName="myname">
                <objectType>TotalCrapFAIL</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
            <Collection articleName="myname">
                <Simple articleName="myname">
                    <objectType>TotalCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
                <Simple articleName="myname">
                    <objectType>YetMoreCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
            </Collection>
         </Input>
         <secondaryArticles>
            <Parameter articleName="limit_by">
               <datatype>INT</datatype>
               <default>10</default>
               <max>100</max>
               <min>1</min>
               <enum>1</enum>
               <enum>2</enum>
               <enum>10</enum>
               <enum>100</enum>
            </Parameter>
         </secondaryArticles>
         <Output>
            <Simple articleName="myoutputname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
         </Output>
      </registerService>};
# register service with invalid object type
TEST(MOBY::Central->registerService($m), 14, 0);






$m=q{      <registerService>
         <Category>moby</Category>
         <serviceName>MyCrappyService</serviceName>
         <serviceType>RetrieveCrap</serviceType>
         <authURI>your.URI.here</authURI>
         <URL>http://URL.to.your/Service.script</URL>;
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authoritativeService>1</authoritativeService>
         <Description><![CDATA[
               human readable COMPREHENSIVE description of your service]]>
         </Description>
         <Input>
            <Simple articleName="myname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
            <Collection articleName="myname">
                <Simple articleName="myname">
                    <objectType>TotalCrap</objectType>
                    <Namespace>Genbank:CrapFAIL</Namespace>
                </Simple>
                <Simple articleName="myname">
                    <objectType>YetMoreCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
            </Collection>
         </Input>
         <secondaryArticles>
            <Parameter articleName="limit_by">
               <datatype>INT</datatype>
               <default>10</default>
               <max>100</max>
               <min>1</min>
               <enum>1</enum>
               <enum>2</enum>
               <enum>10</enum>
               <enum>100</enum>
            </Parameter>
         </secondaryArticles>
         <Output>
            <Simple articleName="myoutputname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
         </Output>
      </registerService>};
# register service with invalid namespace type
TEST(MOBY::Central->registerService($m), 15, 0);




$m = q{<deregisterService>
          <authURI>your.URI.here</authURI>
          <serviceName>MyCrappyService</serviceName>
        </deregisterService>};
# deregister service
TEST(MOBY::Central->deregisterService($m), 16, 1);



$m=q{<deregisterNamespace>
           <namespaceType>Genbank:Crap</namespaceType>
        </deregisterNamespace>};
# deregister unused namespace
TEST(MOBY::Central->deregisterNamespace($m), 17, 1);




$m=q{<deregisterObjectClass>
  <objectType>TotalCrap</objectType>
</deregisterObjectClass>
};
# deregister unused object class
TEST(MOBY::Central->deregisterObjectClass($m), 18, 1);



$m=q{        <deregisterServiceType>
          <serviceType>RetrieveCrap</serviceType>
        </deregisterServiceType>
};
# deregister unused service type
TEST(MOBY::Central->deregisterServiceType($m), 19, 1);


$m=q{<deregisterObjectClass>
  <objectType>YetMoreCrap</objectType>
</deregisterObjectClass>
};
# deregister unused object class
TEST(MOBY::Central->deregisterObjectClass($m), 20, 1);



$m=q{<deregisterObjectClass>
  <objectType>YetMoreCrap</objectType>
</deregisterObjectClass>
};
# deregister non-existent object class
TEST(MOBY::Central->deregisterObjectClass($m), 21, 0);



$m=q{<deregisterNamespace>
           <namespaceType>Genbank:Crap</namespaceType>
        </deregisterNamespace>};
# deregister non-existent namespace
TEST(MOBY::Central->deregisterNamespace($m), 22, 0);



#################################
#################################
#################################
# database should now be empty again!
#################################
#################################
#################################




$m = q{
 <registerObjectClass>
	<objectType>TotalCrap</objectType>
	<Description><![CDATA[
			human readable description
			of data type]]>
	</Description>
	<ISA>
	</ISA>
	<HASA>
	</HASA>
	<authURI>Your.URI.here</authURI>
	<contactEmail>You@your.address.com</contactEmail>
	<Clobber>0 | 1 | 2</Clobber>  
 </registerObjectClass>

};
#reg first object class 
TEST(MOBY::Central->registerObjectClass($m), 23, 1);


$m = q{
 <registerObjectClass>
	<objectType>YetMoreCrap</objectType>
	<Description><![CDATA[
			human readable description
			of data type]]>
	</Description>
	<ISA>
	</ISA>
	<HASA>
	</HASA>
	<authURI>Your.URI.here</authURI>
	<contactEmail>You@your.address.com</contactEmail>
	<Clobber>0 | 1 | 2</Clobber>  
 </registerObjectClass>

};
#reg second object class
TEST(MOBY::Central->registerObjectClass($m), 24, 1);


$m=q{<registerServiceType>
         <serviceType>RetrieveCrap</serviceType>
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authURI>Your.URI.here</authURI>
         <Description>
           <![CDATA[ human description of service type here]]>
         </Description>
         <ISA>
         </ISA>
        </registerServiceType>};
# register first service type
TEST(MOBY::Central->registerServiceType($m), 25, 1);



$m=q{<registerNamespace>
           <namespaceType>Genbank:Crap</namespaceType>
           <contactEmail>your_name@contact.address.com</contactEmail>
           <authURI>Your.URI.here</authURI>
           <Description>
              <![CDATA[human readable description]]>
           </Description>
        </registerNamespace>};
# register first namespace
TEST(MOBY::Central->registerNamespace($m), 26, 1);



$m=q{      <registerService>
         <Category>moby</Category>
         <serviceName>MyCrappyService</serviceName>
         <serviceType>RetrieveCrap</serviceType>
         <authURI>your.URI.here</authURI>
         <URL>http://URL.to.your/Service.script</URL>;
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authoritativeService>1</authoritativeService>
         <Description><![CDATA[
               human readable COMPREHENSIVE description of your service]]>
         </Description>
         <Input>
            <Simple articleName="myname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
            <Collection articleName="myname">
                <Simple articleName="myname">
                    <objectType>TotalCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
                <Simple articleName="myname">
                    <objectType>YetMoreCrap</objectType>
                    <Namespace>Genbank:Crap</Namespace>
                </Simple>
            </Collection>
         </Input>
         <secondaryArticles>
            <Parameter articleName="limit_by">
               <datatype>INT</datatype>
               <default>10</default>
               <max>100</max>
               <min>1</min>
               <enum>1</enum>
               <enum>2</enum>
               <enum>10</enum>
               <enum>100</enum>
            </Parameter>
         </secondaryArticles>
         <Output>
            <Simple articleName="myoutputname">
                <objectType>TotalCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
         </Output>
      </registerService>};
# register first service (valid)
TEST(MOBY::Central->registerService($m), 27, 1);

$m=q{      <registerService>
         <Category>moby</Category>
         <serviceName>MyCrappyService2</serviceName>
         <serviceType>RetrieveCrap</serviceType>
         <authURI>your.URI.here</authURI>
         <URL>http://URL.to.your/Service.script</URL>;
         <contactEmail>your_name@contact.address.com</contactEmail>
         <authoritativeService>1</authoritativeService>
         <Description><![CDATA[
               human readable COMPREHENSIVE description of your service]]>
         </Description>
         <Input>
            <Simple articleName="myname">
                <objectType>YetMoreCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
         </Input>
         <secondaryArticles>
         </secondaryArticles>
         <Output>
            <Simple articleName="myoutputname">
                <objectType>YetMoreCrap</objectType>
                <Namespace>Genbank:Crap</Namespace>
            </Simple>
         </Output>
      </registerService>};
# register second service (valid)
TEST(MOBY::Central->registerService($m), 28, 1);


$m = "<findService>
<inputObjects>
            <Input>
            </Input>
          </inputObjects>
          <outputObjects>
            <Output>
            </Output>
          </outputObjects>
          <serviceType></serviceType>
          <Category></Category>
          <authURI>your.URI.here</authURI>;
          <expandObjects></expandObjects> 
          <expandServices></expandServices>
          <authoritative></authoritative>
          <keywords>
          </keywords>
</findService>";
# find service based on Authority tag
$reg = MOBY::Central->findService($m);
my $n = grep /authURI\s*\=/, split "<", $reg;
if ($n == 2){
    print "test 29\t\t[PASS]\n";
} else {
    print "test 29\n\n[FAIL]\n$reg\n\n";
}


$m = "<findService>
        <inputObjects>
            <Input>
                <Simple>
                    <objectType>TotalCrap</objectType>
                </Simple>
            </Input>
          </inputObjects>
          <outputObjects>
            <Output>
            </Output>
          </outputObjects>
          <serviceType></serviceType>
          <Category></Category>
          <authURI>your.URI.here</authURI>;
          <expandObjects></expandObjects> 
          <expandServices></expandServices>
          <authoritative></authoritative>
          <keywords>
          </keywords>
</findService>";
# find service based on Authority and Objecttag
$reg = MOBY::Central->findService($m);
$n = grep /authURI\s*\=/, split "<", $reg;
if ($n == 1){
    print "test 30\t\t[PASS]\n";
} else {
    print "test 30\n\n[FAIL]\n$reg\n\n";
}


$m = "<findService>
        <inputObjects>
            <Input>
                <Simple>
                    <objectType>TotalCrapFAIL</objectType>
                </Simple>
            </Input>
          </inputObjects>
          <outputObjects>
            <Output>
            </Output>
          </outputObjects>
          <serviceType></serviceType>
          <Category></Category>
          <authURI>your.URI.here</authURI>;
          <expandObjects></expandObjects> 
          <expandServices></expandServices>
          <authoritative></authoritative>
          <keywords>
          </keywords>
</findService>";
# find service based on Authority and INVALID Object
$reg = MOBY::Central->findService($m);
$n = grep /authURI\s*\=/, split "<", $reg;
if ($n == 0){
    print "test 31\t\t[PASS]\n";
} else {
    print "test 31\n\n[FAIL]\n$reg\n\n";
}





$m = q{<deregisterService>
          <authURI>your.URI.here</authURI>
          <serviceName>MyCrappyService</serviceName>
        </deregisterService>};
# deregister service
TEST(MOBY::Central->deregisterService($m), 32, 1);




$m = q{<deregisterService>
          <authURI>your.URI.here</authURI>
          <serviceName>MyCrappyService2</serviceName>
        </deregisterService>};
# deregister service
TEST(MOBY::Central->deregisterService($m), 33, 1);



$m=q{<deregisterNamespace>
           <namespaceType>Genbank:Crap</namespaceType>
        </deregisterNamespace>};
# deregister unused namespace
TEST(MOBY::Central->deregisterNamespace($m), 34, 1);




$m=q{<deregisterObjectClass>
  <objectType>TotalCrap</objectType>
</deregisterObjectClass>
};
# deregister unused object class
TEST(MOBY::Central->deregisterObjectClass($m), 35, 1);



$m=q{        <deregisterServiceType>
          <serviceType>RetrieveCrap</serviceType>
        </deregisterServiceType>
};
# deregister unused service type
TEST(MOBY::Central->deregisterServiceType($m), 36, 1);


$m=q{<deregisterObjectClass>
  <objectType>YetMoreCrap</objectType>
</deregisterObjectClass>
};
# deregister unused object class
TEST(MOBY::Central->deregisterObjectClass($m), 37, 1);


