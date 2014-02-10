use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Style::Maketext;
use Localizer::Resource;
use Localizer::Format::Properties;

subtest 'Properties file of maketext format' => sub {
    my $de = Localizer::Resource->new(
        dictionary => Localizer::Format::Properties->new()->read_file('t/dat/Maketext/de.properties'),
        format => Localizer::Style::Maketext->new,
        functions => {
            dubbil => sub { return $_[0] * 2 },
        },
    );

    is $de->maketext('Hello, World!'), 'Hallo, Welt!', 'simple case';
    is $de->maketext('Goodbye'), 'Goodbye';
    is $de->maketext('Double [dubbil,_1]', 7), 'Doppelt 14';
    is $de->maketext('You have [*,_1,piece] of mail.', 1), 'Sie haben 1 Poststueck.';
    is $de->maketext('You have [*,_1,piece] of mail.', 10), 'Sie haben 10 Poststuecken.';
    is $de->maketext('Price: [#,_1]', 1000000), 'Preis: 1,000,000';
    is $de->maketext('[_1] [_2] [_*]', 1, 2, 3), '123 2 1', 'asterisk interpolation';
    is $de->maketext('[_1,_2,_*]', 1, 2, 3), '12321', 'concatenated variables';
    is $de->maketext('[_1]()', 10), '10()', "concatenated variables";
    is $de->maketext('_key'), '_schlüssel', "keys which start with";
    is $de->maketext("\\n\\nKnowledge\\nAnd\\nNature\\n\\n"), "\n\nIch wuenschte recht gelehrt zu werden,\nUnd moechte gern, was auf der Erden\nUnd in dem Himmel ist, erfassen,\nDie Wissenschaft und die Natur.\n\n", 'multiline';

    my $err = eval { $de->maketext('this is ] an error') };
    is $err, undef, "no return from eval";
    like $@, qr/Unbalanced\s'\]',\sin/ms, '$@ shows that ] was unbalanced';
};

done_testing;

