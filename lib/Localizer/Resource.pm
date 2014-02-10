package Localizer::Resource;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Localizer::Style::Gettext;

our $BUILTIN_FUNCTIONS;
$BUILTIN_FUNCTIONS = {
    sprintf  => sub { sprintf(shift, @_) },
    numf     => sub { # imported by Locale::Maketext
        my($num) = @_[0,1];
        if($num < 10_000_000_000 and $num > -10_000_000_000 and $num == int($num)) {
            $num += 0;  # Just use normal integer stringification.
            # Specifically, don't let %G turn ten million into 1E+007
        }
        else {
            $num = CORE::sprintf('%G', $num);
            # "CORE::" is there to avoid confusion with the above sub sprintf.
        }
        while( $num =~ s/^([-+]?\d+)(\d{3})/$1,$2/s ) {1}  # right from perlfaq5
        # The initial \d+ gobbles as many digits as it can, and then we
        #  backtrack so it un-eats the rightmost three, and then we
        #  insert the comma there.

        return $num;
    },
    numerate => sub { # imported by Locale::Maketext
        # return this lexical item in a form appropriate to this number
        my($num, @forms) = @_;
        my $s = ($num == 1);

        return '' unless @forms;
        if(@forms == 1) { # only the headword form specified
            return $s ? $forms[0] : ($forms[0] . 's'); # very cheap hack.
        }
        else { # sing and plural were specified
            return $s ? $forms[0] : $forms[1];
        }
    },
    quant => sub { # imported by Locale::Maketext
        my($num, @forms) = @_;

        return $num if @forms == 0; # what should this mean?
        return $forms[2] if @forms > 2 and $num == 0; # special zeroth case

        # Normal case:
        # Note that the formatting of $num is preserved.
        return( $BUILTIN_FUNCTIONS->{numf}->($num) . ' ' . $BUILTIN_FUNCTIONS->{numerate}->($num, @forms) );
        # Most human languages put the number phrase before the qualified phrase.
    },
};

use Mouse;

has dictionary => (
    is => 'ro',
    isa => 'HashRef',
    required => 1,
);

has compiled => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{ } },
);

has format => (
    is => 'ro',
    isa => 'Object',
    default => sub { Localizer::Style::Gettext->new() },
);

has functions => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{ } },
);

has fallback_handler => (
    is => 'ro',
    isa => 'CodeRef',
    default => sub {
        sub {
            my ($self, $fmt) = @_;
            warn "Missing localization for '$fmt'";
            $fmt;
        }
    },
);

no Mouse;

sub maketext {
    my ($self, $msgid, @args) = @_;

    my $compiled = $self->compile($msgid);
    return unless defined $compiled;

    if (ref $compiled eq 'CODE') {
        if (0) {
            require B::Deparse;
            my $deparse = B::Deparse->new("-p", "-sC");
            warn $deparse->coderef2text($compiled);
        }
        return $compiled->($self, @args);
    } elsif (ref $compiled eq 'SCALAR') {
        return $$compiled;
    } else {
        die "SHOULD NOT REACH HERE";
    }
}

sub compile {
    my ($self, $msgid) = @_;

    if (my $code = $self->compiled->{$msgid}) {
        return $code;
    }

    my $fmt = $self->dictionary->{$msgid};
    return unless $fmt;
    my $code = $self->format->compile($fmt);
    $self->compiled->{$msgid} = $code;
    return $code;
}

sub call_function {
    my ($self, $name, @args) = @_;
    my $code = $self->functions->{$name} // $BUILTIN_FUNCTIONS->{$name};
    unless ($code) {
        Carp::confess("Unknown function: ${name}");
    }
    my $ret = $code->(@args);
    return $ret;
}

1;

__END__

=head1 SYNOPSIS

    use Localizer;
    use Localizer::Format::Properties;

    my $ja = Localizer::Resource->new(
        dictionary => Localizer::Format::Properties->new->read_file('ja.properties'),
        format => Localizer::Style::Gettext->new(),
    );
    say $ja->maketext("Hi, %1.", 'John');

