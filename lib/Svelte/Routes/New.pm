package Svelte::Routes::New;

use strict;
use warnings;
use diagnostics;

use base 'Exporter';

our @EXPORT_OK = qw(gen_new_page_svelte gen_new_page_server);
use lib "lib";
use Svelte::Funcs;

sub gen_new_page_svelte {
    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name_singular_import, @fields )
      = @_;

    # Data here

    my $has_file = 0;
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";
        if ( $field_type ne "file" ) {

            # Get

        }
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
    }

    print "Has file $has_file \n";

    my $vars = $has_file == 1
      ? qq{
      // let { form }: PageProps = \$props();

      //File Variables
      let accept = "image/*";
      let uuid: string | undefined = \$state();
      let fileUploadDone = \$state(false);
    }
      : qq{
      // Defaults
      // let { form }: PageProps = \$props();

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
      Svelte::Funcs::generate_form_data( $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields );
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

my $template_filename = "/home/pande/bin/lib/" . "Svelte/Templates/routes/new.txt";
    # my $template_filename = "./lib/Svelte/Templates/routes/new.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    Svelte::Funcs::push_data_to_file( $file_name, $template_data );
}

sub gen_new_page_server {

    # my ($file_name) = @_;
    my ( $file_name, $resource_name_import, $resource_name, @fields ) = @_;
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
