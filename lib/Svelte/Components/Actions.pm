package Svelte::Components::Actions;

use strict;
use diagnostics;
use base "Exporter";
use lib "lib";
use Svelte::Funcs;

our @EXPORT_OK = qw(gen_component_actions);

sub gen_component_actions {
    print "Generating component actions.... \n";
    my ( $file_name, $resource_name_import, $resource_name_singular ) = @_;
    my $template = qq{
    //Add Actions to the required +page.server.ts
import { fail, redirect, type Actions } from '\@sveltejs/kit';
import type { FormValidation } from '\$lib/interfaces/types';
import Validator from '\$lib/api/Validator';
import ${resource_name_import}API from '\$lib/api/${resource_name_import}API';



export const actions: Actions = {

  create_${resource_name_singular}: async ({ request }) => {
    let formData = await request.formData()
    let valid = String(formData.get("validation"))
    let redirect_url = String(formData.get("redirect"))
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

    throw redirect(303, redirect_url)

  }
  ,
  update_${resource_name_singular}: async ({ request }) => {
    let formData = await request.formData()
    let valid = String(formData.get("validation"))
    let id = String(formData.get("id"))
    let redirect_url = String(formData.get("redirect"))

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

    throw redirect(303, redirect_url)

  },
  delete_${resource_name_singular}: async ({ request }) => {
    let formData = await request.formData()
    let id = String(formData.get("id"))
    let redirect_url = String(formData.get("redirect"))

    await ${resource_name_import}API.delete(id)
    throw redirect(303, redirect_url)

  }


};



 };

    Svelte::Funcs::push_data_to_file( $file_name, $template );
}

1;
