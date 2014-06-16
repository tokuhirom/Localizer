use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Resource;
use Localizer::Style::Gettext;
use Config::Properties;

my %dat = Config::Properties->new(
    file => "t/dat/es.properties"
)->properties;

my $resource = Localizer::Resource->new(
    dictionary => \%dat,
    style => Localizer::Style::Gettext->new(),
);
ok utf8::is_utf8($resource->maketext('e1')), 'e1';
ok utf8::is_utf8($resource->maketext('e2')), 'e2';

done_testing;

sub slurp_utf8 {
    my $fname = shift;
    open my $fh, '<:encoding(utf-8)', $fname
        or Carp::croak("Can't open '$fname' for reading: '$!'");
    scalar(do { local $/; <$fh> })
}
