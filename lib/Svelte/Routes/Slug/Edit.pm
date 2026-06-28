package Svelte::Routes::Slug::Edit;

use strict;
use diagnostics;
use base "Exporter";

use lib "lib";

use Svelte::Funcs;

our @EXPORT_OK = qw(gen_slug_edit_page_svelte gen_slug_edit_page_ts);

sub gen_slug_edit_page_svelte {
    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name, $resource_name_singular_import, @fields )
      = @_;

    my $imports = qq{
    import type { PageProps } from "./\$types";
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
      // let { form , data}: PageProps = \$props();


      //File Variables
      let accept = "image/*";
      let uuid: string | undefined = \$state();
      let fileUploadDone = \$state(false);
    }
      : qq{
      // Defaults
      //let { form }: PageProps = \$props();


    };

    my $funcs = q{
      function uploadDoneCallBack(status: FileUploadStatus) {
        if (status === 'finished') {
          fileUploadDone = true;
        } else {
          fileUploadDone = false;
        }
      }
      onMount(() => {
        if (browser) {
          uuid = self.crypto.randomUUID();
        }
      });
  };

    my $form =
      Svelte::Funcs::gen_edit_form( $file_name, $resource_name_import,
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

my $template_filename = "/home/pande/bin/lib/" . "Svelte/Templates/routes/edit.txt";
    # my $template_filename = "./lib/Svelte/Templates/routes/edit.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

sub gen_slug_edit_page_ts {
    my ( $file_name, $resource_name_import, $resource_name ) = @_;

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

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

1;
