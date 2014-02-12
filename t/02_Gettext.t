use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Style::Gettext;
use Localizer::Resource;
use Localizer::Format::Properties;

subtest 'Properties file of gettext format' => sub {
    my $de = Localizer::Resource->new(
        dictionary => +{
            %{Localizer::Format::Properties->new()->read_file('t/dat/Gettext/de.properties')},
            '%% \\% ~ [ ]' => '%% \\% ~ [ ]',
            '%unknown()' => '%unknown()',
            q{'} => q{'},
        },
        format => Localizer::Style::Gettext->new,
        functions => {
            dubbil => sub { return $_[0] * 2 },
        },
        precompile => 0,
    );

    is $de->maketext('Hello, World!'), 'Hallo, Welt!', 'simple case';
    is $de->maketext('Double %dubbil(%1)', 7), 'Doppelt 14';
    is $de->maketext('You have %*(%1,piece) of mail.', 1), 'Sie haben 1 Poststueck.';
    is $de->maketext('You have %*(%1,piece) of mail.', 10), 'Sie haben 10 Poststuecken.';
    is $de->maketext('Price: %#(%1)', 1000000), 'Preis: 1,000,000';
    is $de->maketext('%1 %2 %*', 1, 2, 3), '123 2 1', 'asterisk interpolation';
    is $de->maketext('%1%2%*', 1, 2, 3), '12321', 'concatenated variables';
    is $de->maketext('%1()', 10), '10()', 'concatenated variables';
    is $de->maketext('_key'), '_schlüssel', "keys which start with";
    is $de->maketext("\\n\\nKnowledge\\nAnd\\nNature\\n\\n"), "\n\nIch wuenschte recht gelehrt zu werden,\nUnd moechte gern, was auf der Erden\nUnd in dem Himmel ist, erfassen,\nDie Wissenschaft und die Natur.\n\n", 'multiline';
    is $de->maketext('%% \\% ~ [ ]'), '%% \\\\% ~ [ ]', 'Special chars';

    is $de->maketext(q{'}), q{'}, 'One more special char';

    eval { $de->maketext('%unknown()') };
    like $@, qr(Language resource compilation error.);
};

done_testing;

