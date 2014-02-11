package Localizer::Dictionary;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    ro => [qw(entries)],
);

sub new {
    my $class = shift;
    bless {
        entries => {},
    }, $class;
}

sub add_entry {
    my ($self, $msgid, $file, $line) = @_;
    push @{$self->entries->{$msgid}->{position}}, [$file, $line];
}

1;
