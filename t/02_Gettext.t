use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Format::Gettext;
use Localizer::Resource;
use Localizer::Lexicon::Properties qw/read_properties/;

# Steal from Locale::Maketext::Lexicon
subtest 'Properties file of gettext format' => sub {
    my $de = Localizer::Resource->new(
        dictionary => read_properties('t/dat/Gettext/de.properties'),
        format => Localizer::Format::Gettext->new,
    );

    is $de->maketext('Hello, World!'), 'Hallo, Welt!', 'Gettext - simple case';
    is $de->maketext('You have %*(%1,piece) of mail.', 10), 'Sie haben 10 Poststuecken.', 'Gettext - complex case';
    is $de->maketext('%1 %2 %*', 1, 2, 3), '123 2 1', 'Gettext - asterisk interpolation';
    is $de->maketext('%1%2%*', 1, 2, 3), '12321', 'Gettext - concatenated variables';
    is $de->maketext('%1()', 10), '10()', 'Gettext - concatenated variables';
    is $de->maketext("\\n\\nKnowledge\\nAnd\\nNature\\n\\n"), "\n\nIch wuenschte recht gelehrt zu werden,\nUnd moechte gern, was auf der Erden\nUnd in dem Himmel ist, erfassen,\nDie Wissenschaft und die Natur.\n\n", 'Gettext - multiline';
};

done_testing;

