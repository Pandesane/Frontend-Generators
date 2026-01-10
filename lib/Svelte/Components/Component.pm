package Svelte::Components::Component;

use strict;
use diagnostics;
use lib "lib";
use base "Exporter";

use Svelte::Funcs;

our @EXPORT_OK = qw(gen_component);

sub gen_component {
    my ( $file_name, $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;

    print "Generating Compnent... \n";

    my $gen_divs =
      Svelte::Funcs::generate_divs( $resource_name_singular, 0, @fields );

    my $template = qq{
        <script lang="ts">
          import { enhance } from "\$app/forms";
          import { page } from "\$app/state";
          import type I$resource_name_singular_import from "\$lib/interfaces/I$resource_name_singular_import";
          import ${resource_name_singular_import}EditForm from "./${resource_name_singular_import}EditForm.svelte";

            let {
              $resource_name_singular,
              ${resource_name_singular}EditForm,
              relation_id
            }: { ${resource_name_singular}: I${resource_name_singular_import}; ${resource_name_singular}EditForm: any, relation_id: string | number } = \$props();

            let dialogElementEdit: HTMLDialogElement;
          </script>



          <div>

        <div>
                  $gen_divs
                </div>
          <div class="flex justify-around my-4">
            <form action="?/delete_${resource_name_singular}" method="post" use:enhance>
              <input type="hidden" name="id" value={${resource_name_singular}.id} />
              <input type="hidden" name="redirect" value={page.url.href} />

              <button  onclick={(e) => {
                  let btn = e.target as HTMLButtonElement;
                  btn.innerText = "Delete...";
                }}

              class="btn btn-primary" >Delete</button>
            </form>

            <button
              onclick={() => {
                dialogElementEdit.showModal();
              }}
              class="btn btn-primary">Edit</button
            >
          </div>
        </div>

        <!-- Edit ${resource_name_singular_import} File -->
        <dialog bind:this={dialogElementEdit} class="modal">
          <div class="modal-box">
            <${resource_name_singular_import}EditForm
              closeModal={() => {
                dialogElementEdit.close();
              }}
              {${resource_name_singular}}
              {${resource_name_singular}EditForm}
              {relation_id}
            />
            <div class="modal-action">
              <button
                onclick={() => {
                  dialogElementEdit.close();
                }}
                class="btn btn-primary my-4">Close</button
              >
            </div>
          </div>
        </dialog>
 \n

    };

    # print $component;

    Svelte::Funcs::push_data_to_file( $file_name, $template );
}

1;
