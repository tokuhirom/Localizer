package Localizer::Scanner::Xslate;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub DEBUG () { 0 }

use Localizer::Dictionary;

use Class::Accessor::Lite 0.05 (
    ro => [qw(parser)],
);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    my $self = bless { }, $class;
    my $syntax = $args{syntax} || 'TTerse';
    $self->{parser} = $self->_build_parser($syntax);

    return $self;
}

our $RESULT;
our $FILENAME;

sub _build_parser {
    my ($self, $syntax) = @_;

    eval "use Text::Xslate::Syntax::${syntax};"; ## no critic
    die $@ if $@;

    "Text::Xslate::Syntax::${syntax}"->new(),
}

sub scan {
    my($self, $result, $filename, $data) = @_;
    my $ast = $self->parser->parse($data);
    local $FILENAME = $filename;
    local $RESULT = $result;
    $self->walker($ast);
    return $result;
}

sub scan_file {
    my ($self, $result, $filename) = @_;
    open my $fh, '<:encoding(utf-8)', $filename
        or die "Cannot open file '$filename' for reading: $!";
    my $data = do { local $/; <$fh> };
    return $self->scan($result, $filename, $data);
}

my $sp = '';
sub walker {
    my($self, $ast) = @_;
    $ast = [ $ast ] if $ast && ref($ast) eq 'Text::Xslate::Symbol';
    return unless $ast && ref($ast) eq 'ARRAY';

    for my $sym (@{ $ast }) {

        if ($sym->arity eq 'call' && $sym->value eq '(') {
            my $first = $sym->first;
            if ($first && ref($first) eq 'Text::Xslate::Symbol') {
                if ($first->arity eq 'variable' && $first->value eq 'l') {
                    my $second = $sym->second;
                    if ($second && ref($second) eq 'ARRAY' && $second->[0] && ref($second->[0]) eq 'Text::Xslate::Symbol') {
                        my $value = $second->[0];
                        if ($value->arity eq 'literal') {
                            $RESULT->add_entry($value->value, $FILENAME, $value->line);
                        }
                    }
                }
            }
        }

        unless (DEBUG) {
            $self->walker($sym->first);
            $self->walker($sym->second);
            $self->walker($sym->third);
        } else {
            warn "$sp id: " . $sym->id;
            warn "$sp line: " . $sym->line;
            warn "$sp ldp: ". $sym->lbp;
            warn "$sp udp: ". $sym->ubp;
            warn "$sp type: ". $sym->type;

            warn "$sp arity: ". $sym->arity;
            warn "$sp assignment: ". $sym->assignment;
            warn "$sp value: ". $sym->value;

            warn "$sp first: " . $sym->first;
            $sp .= ' ';
            $self->walker($sym->first);
            $sp =~ s/^.//;

            warn "$sp second: " . $sym->second;
            $sp .= ' ';
            $self->walker($sym->second);
            $sp =~ s/^.//;

            warn "$sp third: " . $sym->third;
            $sp .= ' ';
            $self->walker($sym->third);
            $sp =~ s/^.//;

            warn $sp . '----------';
        }
    }
}

1;

