package Localizer::Style::Gettext;
use strict;
use warnings;
use utf8;
use 5.010_001;

use B;
use Carp ();

sub new { bless {}, shift }

sub compile {
    my ($self, $fmt, $functions) = @_;
    my $code = $self->_compile($fmt, $functions);
    return $code;
}

sub _compile {
    my ($self, $str, $functions) = @_;

    return \$str unless $str =~ /%/;

    my @code;
    while ($str =~ m/
            (.*?)
            (?:
                ([\\%]%)
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
            push @code, B::perlstring($text) . ',';
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

            unless (exists $functions->{$function_name}) {
                Carp::confess("Language resource compilation error. Unknown function: '${function_name}'");
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

    if (@code > 1) { # most cases, presumably!
        unshift @code, "join '',\n";
    }
    unshift @code, "use strict; sub {\n";
    push @code, "}\n";

    my $sub = eval(join '', @code); ## no critic.
    die "$@ while evalling" . join('', @code) if $@; # Should be impossible.
    return $sub;
}

1;

