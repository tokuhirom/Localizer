package Localizer::Scanner::Result;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Mouse;

has entries => (
    is => 'ro',
    isa => 'HashRef[ArrayRef[Int]]',
    default => sub { +{ } },
);

no Mouse;

sub add_entry {
    my ($self, $msgid, $file, $line) = @_;
    push @{$self->entries->{$msgid}}, [$file, $line];
}

1;

