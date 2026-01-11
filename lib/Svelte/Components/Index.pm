package Svelte::Components::Index;

use strict;
use diagnostics;

use lib "lib";
use Svelte::Funcs;

use base "Exporter";

our @EXPORT_OK = qw();

sub gen_component_index {
    print "Generating component index.......... \n";
    my ( $file_name, $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields )
      = @_;

    my $template = qq{
<script lang="ts">
  import type I${resource_name_singular_import} from "\$lib/interfaces/I${resource_name_singular_import}";
  import ${resource_name_singular_import}Component from "./${resource_name_singular_import}Component.svelte";
  import ${resource_name_singular_import}NewForm from "./${resource_name_singular_import}NewForm.svelte";
  let dialogElementAdd: HTMLDialogElement;

  let { ${resource_name} , relation_id}: { ${resource_name}: I${resource_name_singular_import}[], relation_id: string | number } = \$props();
    let ${resource_name_singular}NewForm: ${resource_name_singular_import}NewForm;
    let ${resource_name_singular}FormValidation = \$state({
      errors: new Map(),
      success: false,
      successful: new Map(),
      numberOfFields: 2,
    });
</script>

<div class="mx-2 mt-4">
  <div class="flex justify-between">
    <p class="font-medium text-xl">${resource_name_import} Listing</p>
    <button
      onclick={() => {
        dialogElementAdd.showModal();
        ${resource_name_singular}NewForm.resetForm();
      }}
      class="btn btn-link"
    >
      Add
    </button>
  </div>

  <div class="mt-4 w-full">
    {#each ${resource_name} as ${resource_name_singular}}
      <${resource_name_singular_import}Component  {relation_id} {${resource_name_singular}} />
    {/each}
  </div>
</div>

<!-- Add New ${resource_name_singular_import}File -->
<dialog bind:this={dialogElementAdd} class="modal">
  <div class="modal-box">

    <${resource_name_singular_import}NewForm
      bind:this={${resource_name_singular}NewForm}
      ${resource_name_singular}Form={${resource_name_singular}FormValidation}
      closeModal={() => {
        dialogElementAdd.close();
      }}
      {relation_id}
    />

    <div class="modal-action">
      <button
         onclick={() => {
          dialogElementAdd.close();
          ${resource_name_singular}NewForm.cleanUpForm();
        }}
        class="btn btn-primary my-4">Close</button
      >
    </div>
  </div>
</dialog>


    };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

1;
