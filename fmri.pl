use lib '/Home/siv11/ash022/Math-Matlab/lib';
use Math::Matlab;
use Math::Matlab::Local;
  $matlab = Math::Matlab::Local->new({
      cmd      => '/usr/local/bin/matlab -nodisplay -nojvm',
      root_mwd => './'
  });

my $code = q/fprintf( 'Hello world!\n' )/;
if ( $matlab->execute($code) ) {
      print $matlab->fetch_result;
} else {
      print $matlab->err_msg;
}

