package Svelte::Routes::Slug::Index;

use strict;
use warnings;
use diagnostics;
use lib "lib";

use Svelte::Funcs;

use base "Exporter";

our @EXPORT_OK =
  qw(gen_slug_layout_server_ts gen_slug_page_svelte gen_slug_page_ts);

sub gen_slug_page_svelte {
    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name_singular_import,
        $resource_name, @fields )
      = @_;

    my $imports = q{
       import { enhance } from "$app/forms";
       import TopNavBar from "$lib/components/TopNavBar.svelte";
      import type { PageProps } from "./$types";
    };

    my $vars = q{
     const { data }: PageProps = $props();
    };

    my $script = qq{
      <script lang="ts">
      $imports
      $vars
      </script>
    };

    my $gen_divs =
      Svelte::Funcs::generate_divs( $resource_name_singular, 1, @fields );

    my $template = qq{
      $script
      <TopNavBar to="/$resource_name" title={data.$resource_name_singular.name} />

      <div class="mt-18 mx-2">
        <div>
          $gen_divs
        </div>

        <div class="flex w-full justify-around">
          <a href="/$resource_name/{data.$resource_name_singular.id}/edit" class="btn btn-primary my-4"
            >Edit $resource_name_singular</a
          >
          <form action="?/delete" method="POST" use:enhance>
            <input type="hidden" name="id" value={data.$resource_name_singular.id} />
            <button class="btn btn-primary my-4">Delete</button>
          </form>
        </div>
      </div>

    };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

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
