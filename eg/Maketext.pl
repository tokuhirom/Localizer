#!/usr/bin/env perl

use strict;
use warnings;
use Encode qw/encode_utf8/;
use FindBin;

use lib "$FindBin::Bin/../lib";
use Localizer::Resource;
use Localizer::Format::Properties;
use Localizer::Style::Maketext;

my $ja = Localizer::Resource->new(
    dictionary => Localizer::Format::Properties->new->read_file("$FindBin::Bin/Maketext/ja.properties"),
    style      => Localizer::Style::Maketext->new(),
);
print encode_utf8($ja->maketext("Hi, [_1].", 'John')) . "\n";
