package Localizer::Format::Gettext;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Localizer::Format::Maketext);

sub compile {
    my ($self, $fmt) = @_;
    $fmt = $self->_gettext_to_maketext($fmt);
    return $self->SUPER::compile($fmt);
}

# Steal from Maketext:Lexicon::Gettext::_gettext_to_maketext
sub _gettext_to_maketext {
    my ($self, $str) = @_;

    $str =~ s{([\~\[\]])}{~$1}g;
    $str =~ s{
        ([%\\]%)                        # 1 - escaped sequence
    |
        %   (?:
                ([A-Za-z#*]\w*)         # 2 - function call
                    \(([^\)]*)\)        # 3 - arguments
            |
                ([1-9]\d*|\*)           # 4 - variable
            )
    }{
        $1 ? $1
           : $2 ? "\[$2,"._unescape($3)."]"
                : "[_$4]"
    }egx;

    return $str;
}

1;

