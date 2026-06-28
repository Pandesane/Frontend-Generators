package Svelte::Components::Index;

use strict;
use diagnostics;

use base "Exporter";

use lib "lib", "/home/pande/bin/lib";

use Regex::Regex;
use Regex::RegexHelpers;

our @EXPORT_OK = qw(gen_component_index);

sub gen_component_index {
    my ( $file_name, $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;

    my @match_expressions = (
        Regex::Regex->new(
            {
                regex => qr/\{resource_name_singular_import\}/,
                value => ${resource_name_singular_import}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{resource_name_singular\}/,
                value => ${resource_name_singular}
            }
        ),

        Regex::Regex->new(
            {
                regex => qr/\{resource_name\}/,
                value => ${resource_name}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{resource_name_import\}/,
                value => ${resource_name_import}
            }
        ),

    );

my $template_filename = "/home/pande/bin/lib/" . "Svelte/Templates/components/index.txt";
    # my $template_filename = "./lib/Svelte/Templates/components/index.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    Svelte::Funcs::push_data_to_file( $file_name, $template_data );
}

1;
