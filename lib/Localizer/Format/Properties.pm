package Localizer::Format::Properties;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Mouse;

no Mouse;

sub read_file {
    my ($self, $filename) = @_;

    open my $fh, '<:encoding(utf-8)', $filename
        or Carp::croak("Cannot open '$filename' for reading: $!");

    my @out;
    for my $line (<$fh>) {
        if ($line =~ /\A[ \t]*([^=]+?)[ \t]*=[ \t]*(.+?)[\015\012]*\z/) {
            my ($k, $v) = ($1, $2);
            $v =~ s/\\n/\n/g;
            push @out, $k, $v;
        }
    }

    return +{ @out };
}

1;

