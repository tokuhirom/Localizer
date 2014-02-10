use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Format::Gettext;
use Localizer::Resource;
use Localizer::Lexicon::Properties qw/read_properties/;

subtest 'Properties file of gettext format' => sub {
    my $de = Localizer::Resource->new(
        dictionary => read_properties('t/dat/Gettext/de.properties'),
        format => Localizer::Format::Gettext->new,
        functions => {
            dubbil => sub { return $_[0] * 2 },
        },
    );

    is $de->maketext('Hello, World!'), 'Hallo, Welt!', 'simple case';
    is $de->maketext('Goodbye'), 'Goodbye';
    is $de->maketext('Double %dubbil(%1)', 7), 'Doppelt 14';
    is $de->maketext('You have %*(%1,piece) of mail.', 1), 'Sie haben 1 Poststueck.';
    is $de->maketext('You have %*(%1,piece) of mail.', 10), 'Sie haben 10 Poststuecken.';
    is $de->maketext('%1 %2 %*', 1, 2, 3), '123 2 1', 'asterisk interpolation';
    is $de->maketext('%1%2%*', 1, 2, 3), '12321', 'concatenated variables';
    is $de->maketext('%1()', 10), '10()', 'concatenated variables';
    is $de->maketext('_key'), '_schlüssel', "keys which start with";
    is $de->maketext("\\n\\nKnowledge\\nAnd\\nNature\\n\\n"), "\n\nIch wuenschte recht gelehrt zu werden,\nUnd moechte gern, was auf der Erden\nUnd in dem Himmel ist, erfassen,\nDie Wissenschaft und die Natur.\n\n", 'multiline';
    is $de->maketext('%% \% ~ [ ]'), '%% \% ~ [ ]', 'Special chars';
};

done_testing;

