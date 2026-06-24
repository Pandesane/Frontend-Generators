package Svelte::Components::New;

use strict;
use diagnostics;

use base "Exporter";

use lib "lib", "/home/pande/bin/lib";

use Regex::Regex;
use Regex::RegexHelpers;

our @EXPORT_OK = qw(gen_component_new_form);

sub gen_component_new_form {
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

    print "Has file $has_file \n";

    my $default_vars = qq{
       // Defaults
        let { ${resource_name_singular}Form, closeModal , relation_id }: {
                        ${resource_name_singular}Form: any;
                        closeModal: () => void;
                        relation_id : string | number;
                      } = \$props();



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
        let accept = "image/*";
        let uuid: string | undefined = \$state();
        let fileUploadStatus: FileUploadStatus = \$state("start");

          onMount(() => {
            uuid = self.crypto.randomUUID();
            // submitBtn.disabled = true;
          });


        	function uploadDoneCallBack(status: FileUploadStatus) {
            if (status == 'finished') {
              submitBtn.disabled = false;
              formStatus = 'Finished Uploading File to server. Please fill in the required form fields';
            } else {
              submitBtn.disabled = true;
              formStatus = 'Finished Uploading File to server.';
            }
          }
    }
      : qq{
      $default_vars

    };

    my $funcs = qq{
      export function resetForm() {
        form.reset();
        fileUploader.cleanUpResources();
        uploadDoneCallBack('start');
      }
    };

    my $form =
      Svelte::Funcs::generate_form_component_data( $resource_name_import,
        $resource_name_singular, @fields );

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

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/components/new.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
