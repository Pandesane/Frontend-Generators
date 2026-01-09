package Svelte::Components::Edit;

use strict;
use diagnostics;

use lib "lib";
use base "Exporter";

use Svelte::Funcs;

our @EXPORT_OK = qw(gen_component_edit_form);

sub gen_component_edit_form {
    print "Generating compeonet edit form..... \n";
    my ( $file_name, $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;

    my $imports = qq{
      import { enhance } from "\$app/forms";
      import type { FormValidation } from "\$lib/interfaces/types";
      import Validator from "\$lib/api/Validator";
      import FileInputUploader from "\$lib/components/FileInputUploader.svelte";
      import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
      import { page } from "\$app/state";
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
      let { ${resource_name_singular}EditForm, ${resource_name_singular} ,  closeModal } = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");


      //File Variables
      let accept = "image/*";
      let uuid = self.crypto.randomUUID();
      let fileUploadDone = \$state(false);
    }
      : qq{
     // Defaults
      let { ${resource_name_singular}EditForm, ${resource_name_singular} ,  closeModal } = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");



    };

    my $funcs = qq{
      function uploadDoneCallBack(value: boolean) {
      fileUploadDone = value;
      }
      \$effect(() => {
        console.log(${resource_name_singular}EditForm);
        formValidation = ${resource_name_singular}EditForm;
      });
    };

    my $form =
      Svelte::Funcs::gen_component_edit_form( $file_name, $resource_name_import,
        $resource_name_singular, $resource_name, @fields );

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
