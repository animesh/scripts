         use CGI qw/:standard/;
         print header,
               start_html('prog exec.'),
               h1('Personal Data'),
               start_form,
               "NAME : ",textfield('name'),p,
               "SEX : ",
               checkbox_group(-name=>'sex',
                              -values=>['MALE','FEMALE']),p,
               "AGE : ", textfield('age'),p,
               "MARITAL STATUS : ",
               popup_menu(-name=>'marital status',
                          -values=>['MARRIED','BACHELOR']),p,
               submit,
               end_form,
               hr;

          if (param()) {
              print "NAME               : ",em(param('name')),p,
                    "SEX                : ",em(join(", ",param('sex'))),p,
                    "AGE                : ",em(param('age')),p,
                    "MARITAL STATUS     : ",em(param('marital status')),p,
                     hr;
          }