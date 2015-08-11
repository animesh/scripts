    #!/usr/bin/perl -w

    use strict;
    use Spreadsheet::ParseExcel;

    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->Parse('tabn249.xls');

    for my $worksheet ( $workbook->worksheets() ) {

        my ( $row_min, $row_max ) = $worksheet->row_range();
        my ( $col_min, $col_max ) = $worksheet->col_range();

        for my $row ( $row_min .. $row_max ) {
            for my $col ( $col_min .. $col_max ) {

                my $cell = $worksheet->get_cell( $row, $col );
                next unless $cell;

                print "Row, Col    = ($row, $col)\n";
                print "Value       = ", $cell->value(),       "\n";
                print "Unformatted = ", $cell->unformatted(), "\n";
                print "\n";
            }
        }
    }

