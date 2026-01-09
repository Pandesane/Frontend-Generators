package Svelte::Routes::New;

use strict;
use warnings;
use diagnostics;

use base 'Exporter';

our @EXPORT_OK = qw(gen_new_page_svelte gen_new_page_server);
use lib "lib";
use Svelte::Funcs;

sub gen_new_page_svelte {
    my ( $file_name, $resource_name_import,$resource_name_singular, @fields ) = @_;

    # Data here
    my $imports = qq{
  import { enhance } from "\$app/forms";
  import type { PageProps } from "./\$types";
  import Validator from "\$lib/api/Validator";
  import FileInputUploader from "\$lib/components/FileInputUploader.svelte";
  import type { FormValidation } from "\$lib/interfaces/types";
  import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
  };

    my $has_file = 0;
    my $gen_vars = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";
        if ( $field_type ne "file" ) {
            $gen_vars .= qq{
            let $field = \$state("");
            };

        }
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
    }

    print "Has file $has_file \n";

    my $vars = $has_file == 1
      ? qq{
      // Defaults
      let { form }: PageProps = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");

      //State Variables
      $gen_vars

      //File Variables
      let accept = "image/*";
      let uuid = self.crypto.randomUUID();
      let fileUploadDone = \$state(false);
    }
      : qq{
      // Defaults
      let { form }: PageProps = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");

      //State Variables
      $gen_vars

    };

    my $funcs = q{
  function uploadDoneCallBack(value: boolean) {
    fileUploadDone = value;
  }
  $effect(() => {
    console.log(form);
    formValidation = form;
  });
  };

    my $form =
      Svelte::Funcs::generate_form_data( $resource_name_import,
        $resource_name_singular, @fields );

    my $template = qq{
      $form
      };

    my $data = qq{
  <script lang="ts">
  $imports
  $vars
  $funcs
  </script>
  $template
  };

    Svelte::Funcs::push_data_to_file( $file_name, $data );
}

sub gen_new_page_server {

    # my ($file_name) = @_;
    my ( $file_name, $resource_name_import, $resource_name,  @fields ) = @_;
    my $resource_api_url = "/${resource_name}/";

    my $imports = qq{
      import { fail, redirect, type Actions } from "\@sveltejs/kit";
      import type { FormValidation } from "\$lib/interfaces/types";
      import Validator from "\$lib/api/Validator";
      import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
  };

    my $actions = qq{
  export const actions: Actions = {
    create: async ({ request }) => {
      let formData = await request.formData()
      let valid = String(formData.get("validation"))
      let validation: FormValidation | undefined
      if (valid !== "") {
        validation = Validator.getFormValidation(valid)

      }

      // return fail(400, JSON.parse(valid))
      let mapData = Object.fromEntries(formData)
      console.log(mapData)
      // let json = JSON.stringify(mapData)
      // TODO: Add authorization for ${resource_name_import} creation
      mapData = { ...mapData }
      validation = await ${resource_name_import}API.create(mapData, validation)

      if (!validation.success) {
        return fail(400, validation)
      }

      throw redirect(303, "$resource_api_url")

    }

  };
  };
    my $template = qq{
    $imports
    $actions
    };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

1;
