package Localizer::Format::Gettext;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Localizer::Format::Maketext);

use Locale::Maketext::Lexicon::Gettext ();

sub compile {
    my ($self, $fmt) = @_;
    $fmt = Locale::Maketext::Lexicon::Gettext::_gettext_to_maketext($fmt);
    return $self->SUPER::compile($fmt);
}

1;

