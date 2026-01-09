package Svelte::Routes::Index;

use strict;
use diagnostics;

use lib "lib";
use Svelte::Funcs;

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

    # my ($file_name) = @_;
    my $arg_len = scalar(@_);
    print "Arg Length: $arg_len\n";
    foreach my $var (@_) {
        print "$var 1 \n";
    }
    my ( $file_name, $resource_name_import, $resource_name,
        $resource_name_singular, @fields )
      = @_;
    print "Method \@fields @fields \n";
    my $imports = q{
      import type { PageProps } from "./$types";
    };
    my $vars = q{
       let { data }: PageProps = $props();
    };

    my $script = qq{
      <script lang="ts">
      $imports
      $vars
      </script>
    };

    my $form_heading      = "Create New  $resource_name_singular";
    my $form_submit_label = "Create";
    my $form_action       = "?/create";

    my $gen_divs = Svelte::Funcs::generate_divs(
        $resource_name_singular, 0,@fields

    );

    my $resource_template = qq{
    <div class="mx-4">


      <div class="flex justify-between items-baseline-last">
      <p class="my-4">${resource_name} Listing</p>
        <a href="/${resource_name}/new" class="btn btn-link">add</a>
      </div>

      {#each data.${resource_name} as ${resource_name_singular}}
        <a href="/$resource_name/{${resource_name_singular}.id}">
        $gen_divs
        </a>
      {/each}

    </div>
    };

    my $template = qq{
      $script
      $resource_template
    };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

1;
