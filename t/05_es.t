use strict;
use warnings;
use utf8;
use Test::More;

use Localizer::Resource;
use Localizer::Style::Gettext;

my %dat = read_key_value("t/dat/es.properties");

my $resource = Localizer::Resource->new(
    dictionary => \%dat,
    style      => Localizer::Style::Gettext->new(),
);
ok utf8::is_utf8($resource->maketext('e1')), 'e1';
ok utf8::is_utf8($resource->maketext('e2')), 'e2';

done_testing;

sub read_key_value {
    my ($filename, $iolayer) = @_;
    $iolayer //= '<:encoding(utf-8)';

    open my $fh, $iolayer, $filename
        or Carp::croak("Cannot open '$filename' for reading: $!");

    my @out;
    for my $line (<$fh>) {
        if ($line =~ /\A[ \t]*([^=]+?)[ \t]*=[ \t]*(.+?)[\015\012]*\z/) {
            my ($k, $v) = ($1, $2);
            $v =~ s/\\n/\n/g;
            push @out, $k, $v;
        }
    }

    return @out;
}
