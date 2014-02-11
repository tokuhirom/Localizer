package Localizer::Resource;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Localizer::Style::Gettext;
use Localizer::BuiltinFunctions;

our $BUILTIN_FUNCTIONS = {
    numf     => \&Localizer::BuiltinFunctions::numf,
    numerate => \&Localizer::BuiltinFunctions::numerate,
    quant    => \&Localizer::BuiltinFunctions::quant,
    sprintf  => \&Localizer::BuiltinFunctions::sprintf,
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

has style => (
    is => 'ro',
    isa => 'Object',
    default => sub { Localizer::Style::Gettext->new() },
);

has functions => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{ } },
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
    my $code = $self->style->compile($fmt);
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
    use Localizer::Style::Gettext;

    my $ja = Localizer::Resource->new(
        dictionary => Localizer::Format::Properties->new->read_file('ja.properties'),
        style => Localizer::Style::Gettext->new(),
    );
    say $ja->maketext("Hi, %1.", 'John');

