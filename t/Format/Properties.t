use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Format::Properties;

my $props = Localizer::Format::Properties->new->read_file('t/dat/ja.properties');
is $props->{'foo.bar'}, 'ふーばー';
is $props->{'oops'}, "うー\nぷす";
is $props->{'123'}, '456';
is $props->{'ほげ'}, 'ふが';


done_testing;

