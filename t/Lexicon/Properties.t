use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Lexicon::Properties;

my $props = read_properties('t/dat/ja.properties');
is $props->{'foo.bar'}, 'ふーばー';
is $props->{'oops'}, "うー\nぷす";


done_testing;

