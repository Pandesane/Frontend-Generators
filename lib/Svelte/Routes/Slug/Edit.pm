package Svelte::Routes::Slug::Edit;

use strict;
use diagnostics;
use base "Exporter";

our @EXPORT_OK = qw(gen_slug_edit_page_svelte gen_slug_edit_page_ts);

sub gen_slug_edit_page_svelte {
    my ( $file_name, @fields, $resource_name_import ) = @_;

    my $imports = qq{
    import type { PageProps } from "./\$types";
    import { enhance } from "\$app/forms";
    import type { FormValidation } from "\$lib/interfaces/types";
    import Validator from "\$lib/api/Validator";
    import FileInputUploader from "\$lib/components/FileInputUploader.svelte";
    import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";

  };

    my $has_file = 0;
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
    }

    print "Has file $has_file \n";

    my $vars = $has_file == 1
      ? qq{
      // Defaults
      let { form , data}: PageProps = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");


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

    my $script = qq{
      <script lang="ts">
      $imports
      $vars
      $funcs
      </script>
    };

    my $form = gen_edit_form();

    my $template = qq{
      $script
      $form

    };

    push_data_to_file( $file_name, $template );

}

sub gen_slug_edit_page_ts {
    my ( $file_name, @fields, $resource_name_import, $resource_name ) = @_;

    my $imports = qq{
    import { fail, redirect, type Actions } from "\@sveltejs/kit";
    import type { FormValidation } from "\$lib/interfaces/types";
    import Validator from "\$lib/api/Validator";
    import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
  };

    my $actions = qq{
  export const actions: Actions = {

    update: async ({ request }) => {
        let formData = await request.formData()
        let valid = String(formData.get("validation"))
        let id = String(formData.get("id"))
        let validation: FormValidation | undefined
        if (valid !== "") {
            validation = Validator.getFormValidation(valid)

        }

        let mapData = Object.fromEntries(formData)
        console.log(mapData)

        validation = await ${resource_name_import}API.update(Number(id), mapData, validation)

        if (!validation.success) {
            return fail(400, validation)
        }

        throw redirect(303, `/$resource_name/\${id}`)

     }
    };
  };

    my $template = qq{
    $imports
    $actions
  };

    push_data_to_file( $file_name, $template );

}





1;
