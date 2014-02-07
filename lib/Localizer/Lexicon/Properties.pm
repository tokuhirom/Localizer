package Localizer::Lexicon::Properties;
use strict;
use warnings;
use utf8;
use 5.010_001;

use parent qw(Exporter);

our @EXPORT = qw(read_properties);

sub read_properties {
    my $filename = shift;

    open my $fh, '<:encoding(utf-8)', $filename;

    my @out;
    for my $line (<$fh>) {
        if ($line =~ /\A([^=]+)=(.+?)[\015\012]*\z/) {
            my ($k, $v) = ($1, $2);
            $v =~ s/\\n/\n/g;
            push @out, $k, $v;
        }
    }

    return +{ @out };
}

1;

