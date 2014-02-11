#!/usr/bin/env perl

use strict;
use warnings;
use Encode qw/encode_utf8/;
use FindBin;

use lib "$FindBin::Bin/../lib";
use Localizer::Resource;
use Localizer::Format::Properties;
use Localizer::Style::Gettext;

my $ja = Localizer::Resource->new(
    dictionary => Localizer::Format::Properties->new->read_file("$FindBin::Bin/Gettext/ja.properties"),
    style      => Localizer::Style::Gettext->new(),
);
print encode_utf8($ja->maketext("Hi, %1.", 'John')) . "\n";
