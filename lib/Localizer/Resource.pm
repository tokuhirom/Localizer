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

use Class::Accessor::Lite 0.05 (
    rw => [qw(dictionary compiled precompile style functions)],
);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    unless (exists $args{dictionary}) {
        Carp::confess("Missing mandatory parameter: dictionary");
    }

    $args{style} ||= Localizer::Style::Gettext->new();

    my $self = bless {
        compiled   => +{},
        precompile => 1,
        functions  => +{},
        %args,
    }, $class;

    # Compile dictionary data to CodeRef or ScalarRef
    if ($self->precompile) {
        for my $msgid (keys %{$self->dictionary}) {
            $self->compile($msgid);
        }
    }

    return $self;
}

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

