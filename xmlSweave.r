SweaveSyntaxXML <-
    new("SweaveSyntax",
        name = "XML",
        read = new("SweaveSyntaxSlots",
                 doc = c("<doc><!\\[CDATA\\[", "</doc>"),
                 code = c("<code options=\"(.*)\"><!\\[CDATA\\[",
                          "]]></code>"),
                 coderef = "^<coderef>(.*)</coderef>",
                 options = "<options>(.*)</options>",
                 docexpr = "<Sexpr>(.*)</Sexpr>",
                 extension = "\\.xml$",
                 syntaxname = "<SweaveSyntax>(.*)</SweaveSyntax>",
                 bof = c("<\\?xml version=\"1.0\"\\?>",
                         "<!DOCTYPE.*",
                         "^[[:space:]]*$",
                         "<Sweave>"),
                 eof = c("^[[:space:]]*$",
                         "</Sweave>")),
        write = new("SweaveSyntaxSlots",
                    doc = c("<doc><![CDATA[", "", "]]></doc>"),
                    code = c("<code options=\"", "\"><![CDATA[", "]]></code>"),
                    coderef = c("<coderef>", "</coderef>"),
                    options = c("<options>", "</options>"),
                    docexpr = c("<Sexpr>", "</Sexpr>"),
                    extension = ".xml",
                    syntaxname = "<syntax>SweaveSyntaxXML</syntax>",
                    bof = paste("<?xml version=\"1.0\"?>\n",
                                "<!DOCTYPE Sweave SYSTEM \"Sweave.dtd\">\n",
                                "<Sweave>\n", sep=""),
                    eof = "</Sweave>\n"))


SweaveHandlers <- function()
{                       
    data = new("Sweave", syntax=SweaveSyntaxXML)
    
    keepXML = function(x, ..., tagname){
        paste("<", tagname, ">", xmlValue(x),
              "</", tagname, ">", sep="")
    }

    doc = function(x, ...){
        z <- character(0)
        for(y in xmlChildren(x)){
            if(is.character(y))
                z <- c(z, y)
            else
                z <- c(z,unlist(strsplit(xmlValue(y), "\n")))
        }
        data@chunks[[length(data@chunks)+1]] <<-
            new("SweaveDocChunk", text=z)
    }

    code = function(x, ...){
        opts = xmlAttrs(x)["options"]
        if(is.na(opts)) opts="" 
        z <- character(0)
        for(y in xmlChildren(x)){
            if(is.character(y))
                z <- c(z, y)
            else
                z <- c(z,unlist(strsplit(xmlValue(y), "\n")))
        }
        data@chunks[[length(data@chunks)+1]] <<-
            new("SweaveCodeChunk", text=z, optstring=opts)
    }


    list(options=function(x, ...) keepXML(x, ..., tagname="options"),
         coderef=function(x, ...) keepXML(x, ..., tagname="coderef"),
         Sexpr=function(x, ...) keepXML(x, ..., tagname="Sexpr"),
         doc=doc, code=code, data=function(){data})
}

read.xmlSweave <- function(file, options=new("SweaveOptions"),
                           validate=TRUE)
{
    require(XML)
    x <- xmlTreeParse(file=file, validate=validate,
                      handlers=SweaveHandlers())$data()
    x@call <- match.call()
    parseSweaveOptions(x, options)
}
