package Svelte::Components::Component;

use strict;
use diagnostics;
use base "Exporter";

use lib "lib", "/home/pande/bin/lib";

use Regex::Regex;
use Regex::RegexHelpers;

our @EXPORT_OK = qw(gen_component);

sub gen_component {
    my ( $file_name, $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;

    my $gen_divs =
      Svelte::Funcs::generate_divs( $resource_name_singular, 0, @fields );

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
        Regex::Regex->new(
            {
                regex => qr/\{gen_divs\}/,
                value => ${gen_divs}
            }
        ),

    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/components/component.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
