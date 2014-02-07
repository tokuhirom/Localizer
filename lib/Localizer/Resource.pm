package Localizer::Resource;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Localizer::Format::Gettext;

our %BUILTIN_FUNCTIONS = (
    sprintf => sub { sprintf(shift, @_) },
);

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
    default => sub { Localizer::Format::Gettext->new() },
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
    unless (defined $fmt) {
        $fmt = $self->fallback_handler->($self, $msgid);
    }
    my $code = $self->format->compile($fmt);
    $self->compiled->{$msgid} = $code;
    return $code;
}

sub call_function {
    my ($self, $name, @args) = @_;
    my $code = $self->functions->{$name} // $BUILTIN_FUNCTIONS{$name};
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
    use Localizer::Lexicon::Properties qw(read_properties);

    my $ja = Localizer::Resource->new(
        dictionary => read_properties('ja.properties'),
        style => Localizer::Style::Gettext->new(),
    );
    say $ja->maketext("Hi, %1.", 'John');

