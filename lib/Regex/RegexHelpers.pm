package Regex::RegexHelpers;

use strict;
use diagnostics;

use lib "lib";

# use Svelte::Funcs;
use Regex::Regex;
use base "Exporter";

our @EXPORT_OK = qw(regex_template_writer gen_from_regex_template);

# TODO: Find out why opening a file from a package refuses and also passing in a fh refuses
sub regex_template_writer {
    my ( $fh, @match_expressions ) = @_;

      # print("$template_filename \n @match_expressions \n");
      # open my $fh, "<", $template_filename or die "Cannot open file $!";
      my $template = "";
    while ( my $line = <$fh> ) {
        $template .= $line;
    }

    foreach my $regex_class (@match_expressions) {
        my $regex = $regex_class->regex();
        my $value = $regex_class->value();
        $template =~ s/$regex/$value/g;
    }

    return $template;

}



sub gen_from_regex_template {
    my ( $template_filename, @in_match_expressions ) = @_;
    open my $fh, "<", $template_filename or die "Cannot open file $template_filename  => $!";
    my $template = "";
    while ( my $line = <$fh> ) {
        $template .= $line;
    }

    foreach my $regex_class (@in_match_expressions) {
        my $regex = $regex_class->regex();
        my $value = $regex_class->value();
        print("Regex Class: $regex $value \n");
        $template =~ s/$regex/$value/g;
    }

    # print("$template \n");

    return $template;

}



1;
