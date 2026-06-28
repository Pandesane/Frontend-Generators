package Svelte::Components::Edit;

use strict;
use diagnostics;

use lib "lib";
use base "Exporter";

use Svelte::Funcs;

our @EXPORT_OK = qw(gen_component_edit_form);

sub gen_component_edit_form {
    my ( $file_name, $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;

    my $has_file = 0;
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
    }

    my $default_vars = qq{
      // Defaults
      let form: HTMLFormElement;
      let submitBtn: HTMLButtonElement;


    };

    my $vars = $has_file == 1
      ? qq{

         $default_vars
      //File Variables
        let formStatus = \$state("Enabled after file is uploaded to server");
        let uuid: string | undefined = \$state();
        let fileUploader: FileInputUploader;
        let accept = "video/*";
        let fileUploadStatus: FileUploadStatus = \$state("present");


       function uploadDoneCallBack(status: FileUploadStatus) {
          if (status == 'finished') {
            formStatus = 'Finished Uploading File to server. Please fill in the required form fields';
            submitBtn.disabled = false;
          } else {
            formStatus = 'Finished Uploading File to server.';
            submitBtn.disabled = true;
          }
        }

         onMount(() => {
          uuid = self.crypto.randomUUID();
          submitBtn.disabled = false;
        });

    }
      : qq{
          $default_vars
    };

    my $funcs = qq{
        export function resetForm() {
          // form.reset();
          fileUploader.cleanUpResources();
        }

        export function cleanUpForm() {
          fileUploader.cleanUpResources();
        }


    };

    my $form =
      Svelte::Funcs::gen_component_edit_form( $file_name, $resource_name_import,
        $resource_name_singular, $resource_name, @fields );

    my @match_expressions = (
        Regex::Regex->new(
            {
                regex => qr/\{form\}/,
                value => ${form}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{resource_name_singular_import\}/,
                value => ${resource_name_singular_import}
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
                regex => qr/\{resource_name\}/,
                value => ${resource_name}
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
                regex => qr/\{vars\}/,
                value => ${vars}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{funcs\}/,
                value => ${funcs}
            }
        ),

    );

my $template_filename = "/home/pande/bin/lib/" . "Svelte/Templates/components/edit.txt";
    # my $template_filename = "./lib/Svelte/Templates/components/edit.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
