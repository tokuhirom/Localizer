#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Encode qw/encode_utf8/;
use FindBin;

use lib "$FindBin::Bin/../lib";
use Localizer::Resource;
use Localizer::Style::Maketext;

my $ja = Localizer::Resource->new(
    dictionary => +{
        'Hi, [_1].' => 'やあ、[_1]。',
    },
    style      => Localizer::Style::Maketext->new(),
);
print encode_utf8($ja->maketext("Hi, [_1].", 'John')) . "\n";
