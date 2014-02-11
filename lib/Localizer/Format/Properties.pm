package Localizer::Format::Properties;
use strict;
use warnings;
use utf8;
use 5.010_001;

use parent qw(Exporter);

our @EXPORT = qw(read_properties);

sub read_properties {
    my ($filename) = @_;
    Localizer::Format::Properties->new->read_file($filename);
}

sub new { bless {}, shift }

sub read_file {
    my ($self, $filename, $iolayer) = @_;
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

    return +{ @out };
}

1;

