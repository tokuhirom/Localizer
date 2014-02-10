use strict;
use warnings;
use Test::More;

use File::Spec;
use File::Temp;

# We should split this plugin from the core dist.
use Test::Requires 'Text::Xslate';
use Localizer::Scanner::Xslate;

my $result = Localizer::Scanner::Result->new();
my $ext = Localizer::Scanner::Xslate->new(
    syntax => 'TTerse',
);
$ext->scan_file($result, 't/dat/Scanner/xslate.html');
is_deeply $result->entries,
  {
    'nest1'         => [ [ 't/dat/Scanner/xslate.html', 13 ] ],
    'term'          => [ [ 't/dat/Scanner/xslate.html', 1 ], [ 't/dat/Scanner/xslate.html', 7 ] ],
    'nest3'         => [ [ 't/dat/Scanner/xslate.html', 13 ] ],
    'values: %1 %2' => [ [ 't/dat/Scanner/xslate.html', 11 ] ],
    'hello'         => [ [ 't/dat/Scanner/xslate.html', 4 ], [ 't/dat/Scanner/xslate.html', 12 ] ],
    'nest2'         => [ [ 't/dat/Scanner/xslate.html', 13 ] ],
    'word'          => [ [ 't/dat/Scanner/xslate.html', 10 ] ],
    'xslate syntax' => [ [ 't/dat/Scanner/xslate.html', 6 ] ]
  };

done_testing;

sub slurp {
    my $fname = shift;
    open my $fh, '<', $fname
        or Carp::croak("Can't open '$fname' for reading: '$!'");
    do { local $/; <$fh> }
}
