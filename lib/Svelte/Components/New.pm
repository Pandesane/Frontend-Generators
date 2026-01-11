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
      import type { FileUploadStatus, FormValidation } from "\$lib/interfaces/types";
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

    my $default_vars = qq{
       // Defaults
        let { ${resource_name_singular}Form, closeModal , relation_id }: {
                        ${resource_name_singular}Form: any;
                        closeModal: () => void;
                        relation_id : string | number;
                      } = \$props();

        let formValidation: FormValidation | undefined | null = \$state({
          errors: new Map(),
          success: false,
          successful: new Map(),
          numberOfFields: 2,
        });

        let jsonState = \$state("");
        // let form: HTMLFormElement;
          let formStatus = \$state("Enabled after file is uploaded to server");
          let form: HTMLFormElement;
          let submitBtn: HTMLButtonElement;

    };

    my $vars = $has_file == 1
      ? qq{
          $default_vars

          //File Variables
          let fileUploader: FileInputUploader;

        //File Variables
        let accept = "video/*";
        let uuid: string | undefined = \$state();
        let fileUploadStatus: FileUploadStatus = \$state("start");
    }
      : qq{
      $default_vars

    };

    my $funcs = qq{
        onMount(() => {
        uuid = self.crypto.randomUUID();
        console.log(page.url.href);
        });
        function uploadDoneCallBack(status: FileUploadStatus) {
            fileUploadStatus = status;
            if (formValidation?.success == false) {
              formStatus =
                "Finished Uploading File to server. Please fill in the required form fields";
            } else {
              submitBtn.disabled = false;
              formStatus = "Finished Uploading File to server.";
            }
          }

          export function resetForm() {
            form.reset();
          }

          export function disableSubmitBtn() {
              // submitBtn.disabled = true;
            }

          export function cleanUpForm() {
            fileUploader.cleanUpResources();
            formValidation = {
              errors: new Map(),
              success: false,
              successful: new Map(),
              numberOfFields: 2,
            };
            fileUploadStatus = "start";
          }

            \$effect(() => {
              console.log("Running effect...........");
              if (
                formValidation?.successful.size == formValidation?.numberOfFields &&
                fileUploadStatus == "finished"
              ) {
                submitBtn.disabled = false;
              } else {
                submitBtn.disabled = true;
              }
            });

          onMount(() => {
                formValidation = ${resource_name_singular}Form;
            });


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
