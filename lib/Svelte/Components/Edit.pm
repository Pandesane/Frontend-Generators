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
      import type { FileUploadStatus, FormValidation } from "\$lib/interfaces/types";
      import Validator from "\$lib/api/Validator";
      import FileInputUploader from "\$lib/components/FileInputUploader.svelte";
      import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
      import { page } from "\$app/state";
      import type I$resource_name_singular_import from "\$lib/interfaces/I$resource_name_singular_import";
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

    my $default_vars = qq{
      // Defaults
      let {
      ${resource_name_singular}Validation = \$bindable(),
       ${resource_name_singular} ,
       closeModal,
       relation_id } : {
          ${resource_name_singular}Validation: FormValidation;
          ${resource_name_singular}: I$resource_name_singular_import;
          closeModal: () => void;
          relation_id: string | number;
        }
       = \$props();

      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");
      let formStatus = \$state("Enabled after file is uploaded to server");
      let form: HTMLFormElement;
      let submitBtn: HTMLButtonElement;
      let uuid: string | undefined = \$state();


    };

    my $vars = $has_file == 1
      ? qq{

         $default_vars
      //File Variables
        let fileUploader: FileInputUploader;
        let accept = "video/*";
      let fileUploadStatus: FileUploadStatus = \$state("present");




    }
      : qq{
          $default_vars
    };

    my $funcs = qq{


       function uploadDoneCallBack(status: FileUploadStatus) {
          fileUploadStatus = status;
          if (formValidation!.errors.size > 0 && fileUploadStatus == "finished") {
            formStatus =
              "Finished Uploading File to server. Please fill in the required form fields";
          } else {
            formStatus = "Finished Uploading File to server.";
          }
        }

        export function resetForm() {
          form.reset();
          submitBtn.disabled = true;
        }

        export function disableSubmitBtn() {
          // submitBtn.disabled = true;
        }

        export function cleanUpForm() {
          console.log("Running cleanup...");
          // submitBtn.disabled = true;
          fileUploader.cleanUpResources();
        }

        onMount(() => {
          uuid = self.crypto.randomUUID();
          formValidation = ${resource_name_singular}Validation;
          console.log("Edit: ", uuid);
          if (formValidation?.errors.size == 0 && fileUploadStatus == "present") {
            submitBtn.disabled = false;
            console.log("Setting disabled to false from present");
          }
        });

       \$effect(() => {
          if (formValidation?.errors.size == 0) {
            submitBtn.disabled = false;
          }
          if (formValidation?.numberOfFields == formValidation?.successful.size) {
            // Valid form
            submitBtn.disabled = false;
          } else if (
            formValidation?.errors.size == 0 &&
            fileUploadStatus == "finished"
          ) {
            submitBtn.disabled = false;
          } else if (formValidation!.errors.size > 0) {
            submitBtn.disabled = true;
          }
          if (fileUploadStatus == "progress") {
            submitBtn.disabled = true;
          }})
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
