package Svelte::Components::New;

use strict;
use diagnostics;

use lib "lib";
use base "Exporter";

use Svelte::Funcs;

our @EXPORT_OK = qw(gen_component_new_form);

sub gen_component_new_form {
    print "Generating Component New Form....... \n";
    my ( $file_name, $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;
    my $imports = qq{
       import { enhance } from "\$app/forms";
      import Validator from "\$lib/api/Validator";
      import FileInputUploader from "\$lib/components/FileInputUploader.svelte";
      import type { FormValidation } from "\$lib/interfaces/types";
      import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
      import { page } from "\$app/state";
      import { onMount } from "svelte";
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
        let { ${resource_name_singular}Form, closeModal } = \$props();
        let formValidation: FormValidation | undefined | null = \$state();
        let jsonState = \$state("");
        // let form: HTMLFormElement;



        //File Variables
        let accept = "image/*";
        let uuid = self.crypto.randomUUID();
        let fileUploadDone = \$state(false);


    }
      : qq{
      // Defaults
        let { ${resource_name_singular}Form, closeModal } = \$props();
        let formValidation: FormValidation | undefined | null = \$state();
        let jsonState = \$state("");
        // let form: HTMLFormElement;

    };


    my $funcs = qq{
        onMount(() => {
        console.log(page.url.href);
        });
        function uploadDoneCallBack(value: boolean) {
          fileUploadDone = value;
        }
        \$effect(() => {
          console.log(${resource_name_singular}Form);
          formValidation = ${resource_name_singular}Form;
        });

        // TODO: Find a way to invalidated the form data after it has being uploaded to server
        // let submitForm: SubmitFunction = async ({}) => {
        //   return ({ result, formElement }) => {
        //     applyAction(result);
        //     if (result.type == "success") {
        //       formElement.reset();
        //     }
        //   };
        // };
    };

    my $form =
      Svelte::Funcs::generate_form_component_data( $resource_name_import,
        $resource_name_singular, @fields );

    my $template = qq{
      <script lang="ts">
        $imports
        $vars
        $funcs
      </script>

      $form

    };

    Svelte::Funcs::push_data_to_file( $file_name, $template );
}

1;
