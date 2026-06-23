package Svelte::Routes::Index;

use strict;
use diagnostics;

# use lib "lib";
use lib "lib", "/home/pande/bin/lib";

use Svelte::Funcs;
use Regex::Regex;
use Regex::RegexHelpers;


use base "Exporter";

our @EXPORT_OK = qw(gen_index_page_svelte gen_index_page_ts);

sub gen_index_page_ts {

    # my ($file_name) = @_;
    my ( $file_name, $resource_name_import, $resource_name, @fields ) = @_;

    my $imports = qq{
      import type { PageServerLoad } from './\$types';
      import ${resource_name_import}API from '\$lib/api/${resource_name_import}API';

    };

    my $load = qq{
      export const load: PageServerLoad = async ({ }) => {
        let $resource_name = await ${resource_name_import}API.list()
        console.log($resource_name)
        return { $resource_name: $resource_name };
      }
    };

    my $template = qq{
      $imports
      $load
    };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

sub gen_index_page_svelte {
    my ( $file_name, $resource_name_import, $resource_name,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;

    my $gen_divs = Svelte::Funcs::generate_divs(
        $resource_name_singular, 0,@fields

    );

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
         Regex::Regex->new(
            {
                regex => qr/\{gen_divs\}/,
                value => ${gen_divs}
            }
        ),


    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/routes/index.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );


    # print $template_data;


    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
