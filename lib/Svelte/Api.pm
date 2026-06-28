package Svelte::Api;

use strict;
use diagnostics;

use base "Exporter";
# use lib "lib";
use lib "lib", "/home/pande/bin/lib";

use Svelte::Funcs;
use Regex::Regex;
use Regex::RegexHelpers;


our @EXPORT_OK = qw(gen_resource_api);

sub gen_resource_api {

    my ( $file_name, $resource_name_singular_import,
        $resource_name_import, $resource_name )
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


    );

my $template_filename = "/home/pande/bin/lib/" . "Svelte/Templates/api.txt";
    # my $template_filename = "./lib/Svelte/Templates/api.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );


    print $template_data;


    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
