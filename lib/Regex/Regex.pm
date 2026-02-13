package Regex::Regex;

use strict;
use diagnostics;

sub new {
    my ( $class, $args ) = @_;

    return bless {
        regex => $args->{regex},
        value => $args->{value}
    }, $class;
}

sub regex {
    my ( $class, $args ) = @_;

    return $class->{regex};
}

sub value {
    my ( $class, $args ) = @_;

    return $class->{value};
}
1;
