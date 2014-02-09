use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Format::Maketext;
use Localizer::Resource;
use Localizer::Lexicon::Properties qw/read_properties/;

subtest 'Properties file of Maketext format' => sub {
    my $de = Localizer::Resource->new(
        dictionary => read_properties('t/dat/Maketext/de.properties'),
        format => Localizer::Format::Maketext->new,
        functions => {
            dubbil => sub { return $_[0] * 2 },
        },
    );

    is $de->maketext('Good morning'), 'Guten Morgen';
    is $de->maketext('Goodbye'), 'Goodbye';

    is $de->maketext('double', 7), 'doppelt 14';
    is $de->maketext('quant', 7), '7 zazen';
    is $de->maketext('quant_astarisk', 7), '7 zazen';

    my $err = eval { $de->maketext('this is ] an error') };
    is $err, undef, "no return from eval";
    like $@, qr/Unbalanced\s'\]',\sin/ms, '$@ shows that ] was unbalanced';

    is $de->maketext('Hey, [_1]', 'you'), 'Hey, you', "keys with bracket notation ok";
    is $de->maketext('_key'), '_schlüssel', "keys which start with _ ok";
};

done_testing;

