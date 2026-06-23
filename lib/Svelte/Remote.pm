package Svelte::Remote;

use strict;
use diagnostics;

use base "Exporter";
# use lib "lib";
use lib "lib", "/home/pande/bin/lib";

use Svelte::Funcs;
use Regex::Regex;
use Regex::RegexHelpers;


our @EXPORT_OK = qw(gen_remote_functions);

sub gen_remote_functions {

    my ( $file_name, $resource_name_singular_import,
        $resource_name_import, $resource_name, $resource_name_singular )
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
                regex => qr/\{resource_name_import\}/,
                value => ${resource_name_import}
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
                regex => qr/\{resource_name_singular\}/,
                value => ${resource_name_singular}
            }
        ),


    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/remote.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );


    print $template_data;


    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
