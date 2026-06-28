package Svelte::Routes::Slug::Index;

use strict;
use warnings;
use diagnostics;
# use lib "lib";
use lib "lib", "/home/pande/bin/lib";

use Svelte::Funcs;
use Regex::Regex;
use Regex::RegexHelpers;

use base "Exporter";

our @EXPORT_OK =
  qw(gen_slug_layout_server_ts gen_slug_page_svelte gen_slug_page_ts);

sub gen_slug_page_svelte {
    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name_singular_import,
        $resource_name, @fields )
      = @_;

    my $gen_divs =
      Svelte::Funcs::generate_divs( $resource_name_singular, 1, @fields );




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


my $template_filename = "/home/pande/bin/lib/" . "Svelte/Templates/routes/slug.txt";

#  my $template_filename = "./lib/Svelte/Templates/routes/slug.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );




    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

sub gen_slug_page_ts {
    my ( $file_name, $resource_name_import, $resource_name ) = @_;
    my $imports = qq{
    import ${resource_name_import}API from '\$lib/api/${resource_name_import}API';
    import { redirect, type Actions } from '\@sveltejs/kit';
    import type { PageServerLoad } from './\$types';

  };

    my $actions = qq{
  export const actions: Actions = {
  delete: async ({ request }) => {
    let formData = await request.formData()
    let id = String(formData.get("id"))
    await ${resource_name_import}API.delete(id)
    throw redirect(303, `/$resource_name/`)

    }

  };
  };

    my $template = qq{
    $imports
    $actions
  };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

sub gen_slug_layout_server_ts {
    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name_singular_import, @fields )
      = @_;

    my $imports = qq{
    import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
    import type I${resource_name_singular_import} from "\$lib/interfaces/I${resource_name_singular_import}";
    import type { LayoutServerLoad } from "./\$types";
  };

    my $load = qq{
  export const load: LayoutServerLoad = async ({ params }) => {
  let $resource_name_singular: I${resource_name_singular_import} = await ${resource_name_import}API.get${resource_name_singular_import}(params.slug)


  console.log($resource_name_singular)
  return { $resource_name_singular: $resource_name_singular };
  }
  };

    my $template = qq{
    $imports
    $load

  };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

1;
