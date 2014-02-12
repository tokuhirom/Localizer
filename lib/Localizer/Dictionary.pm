package Localizer::Dictionary;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    ro => [qw(_entries)],
);

sub new {
    my $class = shift;
    bless {
        _entries => {},
    }, $class;
}

sub exists_msgid {
    my ($self, $msgid) = @_;
    exists $self->_entries->{$msgid}
}

sub add_entry_position {
    my ($self, $msgid, $file, $line) = @_;
    push @{$self->_entries->{$msgid}->{position}}, [$file, $line];
}

1;
