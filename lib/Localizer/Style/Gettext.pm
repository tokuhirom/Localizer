package Localizer::Style::Gettext;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Localizer::Style::Maketext);

sub compile {
    my ($self, $fmt) = @_;
    my $code = $self->_compile($fmt);
    return $code;
}

sub _compile {
    my ($self, $str) = @_;

    my @code;
    while ($str =~ m/
            (.*?)
            (?:
                (%%|\\%)
                |
                %(?:
                    ([A-Za-z#*]\w*)\(([^\)]*)\)
                    |
                    ([1-9]\d*|\*)
                )
                |
                $
            )
        /gsx
    ) {
        if ($1) {
            my $text = $1;
            $text =~ s/\\/\\\\/g;
            push @code, "'" . $text . "',";
        }
        if ($2) {
            my $text = $2;
            $text =~ s/\\/\\\\\\\\/g;
            push @code, "'" . $text . "',";
        }
        elsif ($3) {
            my $function_name = $3;
            if ($function_name eq '*') {
                $function_name = 'quant';
            }
            elsif ($function_name eq '#') {
                $function_name = 'numf';
            }

            my $code = q{$_[0]->call_function('} . $function_name . q{', };
            for my $arg (split(/,/, $4)) {
                if (my $num = $arg =~ /%(.+)/) {
                    $code .= '$_[' . $num . '], ';
                }
                else {
                    $code .= "'" . $arg . "', ";
                }
            }
            $code .= '), ';
            push @code, $code;
        }
        elsif ($5) {
            my $arg = $5;

            my $var = '';
            if ($arg eq '*') {
                $var = '@_[1 .. $#_],';
            }
            else {
                $var = '$_[' . $arg . '],';
            }
            push @code, $var;
        }
    }

    if(@code == 0) { # not possible?
        return \'';
    }
    elsif(@code > 1) { # most cases, presumably!
        unshift @code, "join '',\n";
    }
    unshift @code, "use strict; sub {\n";
    push @code, "}\n";

    my $sub = eval(join '', @code); ## no critic.
    die "$@ while evalling" . join('', @code) if $@; # Should be impossible.
    return $sub;
}

1;

