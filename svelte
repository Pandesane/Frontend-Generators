#!/usr/bin/perl

# svelte gen.resource product name:text description:textarea file:file

# Run formatter for all files in the project

$type      = $ARGV[0];
$type_name = $ARGV[1];
@fields    = @ARGV[ 2 .. ( scalar(@ARGV) - 1 ) ];

# Resouce name ie products and product
$resource_name = lc($type_name);
$resource_name_singular =
  substr( $resource_name, 0, length($resource_name) - 1 );
$resource_name_import          = ucfirst($resource_name);
$resource_name_singular_import = ucfirst($resource_name_singular);

if ( $type eq "help" || $type eq "--help" || $type eq "-h" ) {
    $help = qq{
      ``` $ svelte gen.resource[:layout] resource [(field_type):(input_type) ...] ```

      ``` $ svelte gen.resource:app_layout shops name:text description:textarea file:file ```

      layout -> app_layout Note: Can only allow one parent layout
      resource -> shops
      fields -> name:text description:textarea file:file

      Fields
      (field_type):(input_type)
      e.g. From above
      name:text -> field_type = name and input_type = text




      ``` $ svelte (help | -h | --help) ```
      Outputs help information

  };

    print $help;
}
elsif ( $type =~ "gen.resource" ) {

    my ( $_ignore, $layout ) = split( ":", $type );
    print("Got layout of file: $layout \n");
    $routes_base_path = "src/routes/$type_name";

    if ($layout) {
        $routes_base_path = "src/routes/($layout)/$type_name";
    }
    if ( -d $routes_base_path ) {
        print "Resource already created. \n";
        exit("Resource already created.");
    }
    print "Generating resource: $resource_name \n";

    # Make resource directories
    # system("mkdir " ,"$routes_base_path" );
    `mkdir -p "$routes_base_path"`;
    `mkdir -p "$routes_base_path/new"`;
    `mkdir -p "$routes_base_path/[slug]"`;
    `mkdir -p "$routes_base_path/[slug]/edit"`;

    $lib_base_path = "src/lib/";
    `mkdir -p $lib_base_path`;
    `mkdir -p $lib_base_path/api/`;
    `mkdir -p $lib_base_path/schemas/`;
    `mkdir -p $lib_base_path/interfaces/`;

    # # Make index files
    $index_path = $routes_base_path;
    `touch "$index_path/+page.svelte"`;
    gen_index_page_svelte("$index_path/+page.svelte");
    `touch "$index_path/+page.server.ts"`;
    gen_index_page_ts("$index_path/+page.server.ts");

    # Make new files
    $new_path = "$routes_base_path/new";
    `touch "$new_path/+page.svelte"`;
    $form_title        = "Create New $resource_name_singular";
    $form_submit_label = "Create";
    $form_action       = "?/create";
    gen_new_page_svelte("$new_path/+page.svelte");
    `touch "$new_path/+page.server.ts"`;
    gen_new_page_server("$new_path/+page.server.ts");

    # Make slug layout file
    $slug_path = "$routes_base_path/[slug]";
    `touch "$slug_path/+layout.server.ts"`;
    gen_slug_layout_server_ts("$slug_path/+layout.server.ts");

    # Make show files
    `touch "$slug_path/+page.svelte"`;
    gen_slug_page_svelte("$slug_path/+page.svelte");
    `touch "$slug_path/+page.server.ts"`;
    gen_slug_page_ts("$slug_path/+page.server.ts");

    # Make edit files
    $edit_path = "$routes_base_path/[slug]/edit";
    `touch "$edit_path/+page.svelte"`;
    $form_title        = "Edit $resource_name_singular";
    $form_submit_label = "Save";
    $form_action       = "?/update";
    gen_slug_edit_page_svelte("$edit_path/+page.svelte");
    `touch "$edit_path/+page.server.ts"`;
    gen_slug_edit_page_ts("$edit_path/+page.server.ts");

    # Resource schema
    $schema_path =
      "$lib_base_path/schemas/${resource_name_singular_import}Schema.ts";
    `touch "$schema_path"`;
    gen_resource_schema("$schema_path");

    # Resource API
    $api_path = "$lib_base_path/api/${resource_name_import}API.ts";
    `touch "$api_path"`;
    gen_resource_api("$api_path");

    # Resource interface
    $interface_path =
      "$lib_base_path/interfaces/I${resource_name_singular_import}.ts";
    `touch "$interface_path"`;
    gen_resource_interface("$interface_path");

    # TODO: Run prettier formatter
}

sub gen_resource_interface {
    my ($file_name) = @_;

    $gen_fields = "";
    foreach $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type ne "file" ) {
            $gen_fields .= qq{
            $field: string,
        };
        }

    }

    $template = qq{
        export default interface I$resource_name_singular_import {
          id: string,
          // create_at: string,
          // updated_at: string,
          $gen_fields
        }
    };

    push_data_to_file( $file_name, $template );

}

sub gen_resource_api {

    my ($file_name) = @_;
    $template = qq{
      import { ${resource_name_singular_import}SchemaMap } from "\$lib/schemas/${resource_name_singular_import}Schema"
      import API from "./API"

      class ${resource_name_import}Api extends API {

        constructor() {
          super(${resource_name_singular_import}SchemaMap, "http://localhost:5000/api/$resource_name")
        }

        async get${resource_name_singular_import}(slug: string): Promise<any> {
          return await super.get(slug)

        }


      }
      const ${resource_name_import}API = new ${resource_name_import}Api()

      export default ${resource_name_import}API
  };

    push_data_to_file( $file_name, $template );

}

sub gen_resource_schema {
    my ($file_name) = @_;
    $gen_fields = gen_schema_fields();
    $template   = qq{
     import * as z from "zod";

      export const ${resource_name_singular_import}SchemaMap: Record<string, z.ZodString> = {
        $gen_fields
      }
      const ${resource_name_singular_import}Schema = z.object(${resource_name_singular_import}SchemaMap);

      export default ${resource_name_singular_import}Schema
  };

    push_data_to_file( $file_name, $template );

}

sub gen_schema_fields {
    $gen_fields = "";
    foreach $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type ne "file" ) {
            $gen_fields .= qq{
            $field: z.string(),
        };
        }

    }
    return $gen_fields;
}

sub gen_slug_layout_server_ts {
    my ($file_name) = @_;

    $imports = qq{
    import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
    import type I${resource_name_singular_import} from "\$lib/interfaces/I${resource_name_singular_import}";
    import type { LayoutServerLoad } from "./\$types";
  };

    $load = qq{
  export const load: LayoutServerLoad = async ({ params }) => {
  let $resource_name_singular: I${resource_name_singular_import} = await ${resource_name_import}API.get${resource_name_singular_import}(params.slug)


  console.log($resource_name_singular)
  return { $resource_name_singular: $resource_name_singular };
  }
  };

    $template = qq{
    $imports
    $load

  };

    push_data_to_file( $file_name, $template );

}

sub gen_slug_edit_page_ts {
    my ($file_name) = @_;

    $imports = qq{
    import { fail, redirect, type Actions } from "\@sveltejs/kit";
    import type { FormValidation } from "\$lib/interfaces/types";
    import Validator from "\$lib/api/Validator";
    import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
  };

    $actions = qq{
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

    $template = qq{
    $imports
    $actions
  };

    push_data_to_file( $file_name, $template );

}

sub gen_slug_edit_page_svelte {
    my ($file_name) = @_;
    $imports = qq{
    import type { PageProps } from "./\$types";
    import { enhance } from "\$app/forms";
    import type { FormValidation } from "\$lib/interfaces/types";
    import Validator from "\$lib/api/Validator";
    import FileInputUploader from "\$lib/components/FileInputUploader.svelte";
    import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";

  };

    $has_file = 0;
    foreach $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
    }

    print "Has file $has_file \n";

    $vars = $has_file == 1
      ? qq{
      // Defaults
      let { form , data}: PageProps = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");


      //File Variables
      let accept = "image/*";
      let uuid = self.crypto.randomUUID();
      let fileUploadDone = \$state(false);
    }
      : qq{
      // Defaults
      let { form }: PageProps = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");


    };

    $funcs = q{
  function uploadDoneCallBack(value: boolean) {
    fileUploadDone = value;
  }
  $effect(() => {
    console.log(form);
    formValidation = form;
  });
  };

    $script = qq{
      <script lang="ts">
      $imports
      $vars
      $funcs
      </script>
    };

    $form = gen_edit_form();

    $template = qq{
      $script
      $form

    };

    push_data_to_file( $file_name, $template );

}

sub get_edit_input {
    my ( $field_name, $field_type ) = @_;
    print "Sub input $field_type \n";
    if ( $field_type eq "text" ) {
        print "Creating text input.... \n";
        $input = qq{
          <div class="my-4 flex flex-col">
            <label for="name">$field_name</label>
            <input type="text" id="$field_name" value={data.${resource_name_singular}.$field_name} name="$field_name" />
            {#if !formValidation?.success}
              <!-- content here -->
              <p class="text-red-600 mt-2">{formValidation?.errors.get("$field_name")}</p>
            {/if}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "textarea" ) {
        print "Creating textarea.... \n";
        $input = qq{
          <div class="my-4 flex flex-col">
            <label for="$field_name">$field_name</label>
            <textarea name="$field_name" id="$field_name" value={data.${resource_name_singular}.$field_name}
            ></textarea>
            {#if !formValidation?.success}
              <!-- content here -->
              <p class="text-red-600 mt-2">
                {formValidation?.errors.get("$field_name")}
              </p>
            {/if}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "file" ) {
        print "Creating file input.... \n";
        $input = qq{
            <input value={uuid} type="hidden" name="uuid" />
            <FileInputUploader {accept} {uuid} {uploadDoneCallBack} label="$type_name Poster" />

        };
        return $input;
    }
    else {
        print "Unknown input type";

    }
}

sub gen_edit_form {

    my ($form_type) = @_;
    print "Generating form fields... \n";
    my (@fields)   = @ARGV[ 2 .. ( scalar(@ARGV) - 1 ) ];
    my $gen_form   = "";
    my $form_title = qq{
    <p class="text-center">$form_title</p>
    };

    $has_file = 0;

    foreach $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";
        $input = get_edit_input( $field, $field_type );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
        $gen_form .= $input;
    }

    $form_submit_button = $has_file == 1
      ? qq{
        <button class="btn btn-primary w-full" disabled={!fileUploadDone}
        >$form_submit_label</button
      >
      <p class="text-sm font-light my-2">
        Enabled after file is uploaded to server
      </p>
    }
      : qq{
     <button class="btn btn-primary w-full">$form_submit_label</button>
     };

    $form = qq{
        <form
          onchange={(e) => {
            formValidation = { ...${resource_name_import}API.validator.validateForm(e, formValidation) };
            let json = Validator.setFormValidation(formValidation);
            jsonState = json;
          }}
          class="mx-4 mt-8"
          action="$form_action"
          method="POST"
          enctype="multipart/form-data"
          use:enhance
        >
        $form_title
        <input type="hidden" name="validation" value={jsonState} />
        <input type="hidden" name="id" value={data.${resource_name_singular}.id} />

        $gen_form
        $form_submit_button
        </form>

    };

    return $form;
}

sub gen_slug_page_ts {
    my ($file_name) = @_;
    $imports = qq{
    import ${resource_name_import}API from '\$lib/api/${resource_name_import}API';
    import { redirect, type Actions } from '\@sveltejs/kit';
    import type { PageServerLoad } from './\$types';

  };

    $actions = qq{
  export const actions: Actions = {
  delete: async ({ request }) => {
    let formData = await request.formData()
    let id = String(formData.get("id"))
    await ${resource_name_import}API.delete(id)
    throw redirect(303, `/$resource_name/`)

    }

  };
  };

    $template = qq{
    $imports
    $actions
  };

    push_data_to_file( $file_name, $template );

}

sub gen_slug_page_svelte {
    my ($file_name) = @_;

    $imports = q{
       import { enhance } from "$app/forms";
       import TopNavBar from "$lib/components/TopNavBar.svelte";
      import type { PageProps } from "./$types";
    };

    $vars = q{
     const { data }: PageProps = $props();
    };

    $script = qq{
      <script lang="ts">
      $imports
      $vars
      </script>
    };

    $gen_divs = generate_divs();

    $template = qq{
      $script
      <TopNavBar to="/$resource_name" title={data.$resource_name_singular.name} />

      <div class="mt-14 mx-2">
        <div>
          $gen_divs
        </div>

        <div class="flex w-full justify-around">
          <a href="/$resource_name/{data.$resource_name_singular.id}/edit" class="btn btn-primary my-4"
            >Edit $resource_name_singular</a
          >
          <form action="?/delete" method="POST" use:enhance>
            <input type="hidden" name="id" value={data.$resource_name_singular.id} />
            <button class="btn btn-primary my-4">Delete</button>
          </form>
        </div>
      </div>

    };

    push_data_to_file( $file_name, $template );

}

sub generate_divs {
    $gen_divs = "";
    foreach $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type eq "file" ) {
            $gen_divs .= qq{
            <!-- <div class="font-semibold mt-2">{data.$resource_name_singular.$field}</div> -->
        };
        }
        else {
            $gen_divs .= qq{
            <div class="font-semibold mt-2">{data.$resource_name_singular.$field}</div>
        };

        }
    }

    return $gen_divs;
}

sub gen_index_page_ts {
    my ($file_name) = @_;

    $imports = qq{
      import type { PageServerLoad } from './\$types';
      import ${resource_name_singular_import}API from '\$lib/api/${resource_name_singular_import}API';

    };

    $load = qq{
      export const load: PageServerLoad = async ({ }) => {
        let $resource_name = await ${resource_name_singular_import}API.list()
        console.log($resource_name)
        return { $resource_name: $resource_name };
      }
    };

    $template = qq{
      $imports
      $load
    };

    push_data_to_file( $file_name, $template );

}

sub gen_index_page_svelte {
    my ($file_name) = @_;
    $imports = q{
      import type { PageProps } from "./$types";
    };
    $vars = q{
       let { data }: PageProps = $props();
    };

    $script = qq{
      <script lang="ts">
      $imports
      $vars
      </script>
    };

    $gen_divs = generate_divs();

    $resource_template = qq{
    <div class="mx-4">
      <p class="my-4">${resource_name} Listing</p>

      {#each data.${resource_name} as ${resource_name_singular}}
        <a href="/$resource_name/{${resource_name_singular}.id}">
        $gen_divs
        </a>
      {/each}

    </div>
    };

    $template = qq{
      $script
      $resource_template
    };

    push_data_to_file( $file_name, $template );

}

sub gen_new_page_server {
    my ($file_name) = @_;
    $resource_api_normalize = lc($type_name);
    $resource_api_url       = "/${resource_api_normalize}/";

    # $resource_api           = ucfirst($resource_api_normalize);
    $imports = qq{
      import { fail, redirect, type Actions } from "\@sveltejs/kit";
      import type { FormValidation } from "\$lib/interfaces/types";
      import Validator from "\$lib/api/Validator";
      import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
  };

    $actions = qq{
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
    $template = qq{
    $imports
    $actions
  };

    push_data_to_file( $file_name, $template );

}

sub gen_new_page_svelte {
    my ($file_name) = @_;

    # Data here
    $imports = qq{
  import { enhance } from "\$app/forms";
  import type { PageProps } from "./\$types";
  import Validator from "\$lib/api/Validator";
  import FileInputUploader from "\$lib/components/FileInputUploader.svelte";
  import type { FormValidation } from "\$lib/interfaces/types";
  import ${resource_name_import}API from "\$lib/api/${resource_name_import}API";
  };

    $has_file = 0;
    $gen_vars = "";
    foreach $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";
        if ( $field_type ne "file" ) {
            $gen_vars .= qq{
            let $field = \$state("");
            };

        }
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
    }

    print "Has file $has_file \n";

    $vars = $has_file == 1
      ? qq{
      // Defaults
      let { form }: PageProps = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");

      //State Variables
      $gen_vars

      //File Variables
      let accept = "image/*";
      let uuid = self.crypto.randomUUID();
      let fileUploadDone = \$state(false);
    }
      : qq{
      // Defaults
      let { form }: PageProps = \$props();
      let formValidation: FormValidation | undefined | null = \$state();
      let jsonState = \$state("");

      //State Variables
      $gen_vars

    };

    $funcs = q{
  function uploadDoneCallBack(value: boolean) {
    fileUploadDone = value;
  }
  $effect(() => {
    console.log(form);
    formValidation = form;
  });
  };

    $form = generate_form_data();

    $template = qq{
      $form
      };

    $data = qq{
  <script lang="ts">
  $imports
  $vars
  $funcs
  </script>
  $template
  };

    push_data_to_file( $file_name, $data );
}

sub push_data_to_file() {
    my ( $filename, $data ) = @_;
    open my $fh, ">", $filename or die "Cannot open file $filename";
    print $fh "$data \n";
}

sub generate_form_data() {

    my ($form_type) = @_;
    print "Generating form fields... \n";
    my (@fields)   = @ARGV[ 2 .. ( scalar(@ARGV) - 1 ) ];
    my $gen_form   = "";
    my $form_title = qq{
    <p class="text-center">$form_title</p>
    };

    $has_file = 0;

    foreach $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";
        $input = get_input( $field, $field_type );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
        $gen_form .= $input;
    }

    $form_submit_button = $has_file == 1
      ? qq{
        <button class="btn btn-primary w-full" disabled={!fileUploadDone}
        >$form_submit_label</button
      >
      <p class="text-sm font-light my-2">
        Enabled after file is uploaded to server
      </p>
    }
      : qq{
     <button class="btn btn-primary w-full">$form_submit_label</button>
     };

    $form = qq{
        <form
          onchange={(e) => {
            formValidation = { ...${resource_name_import}API.validator.validateForm(e, formValidation) };
            let json = Validator.setFormValidation(formValidation);
            jsonState = json;
          }}
          class="mx-4 mt-8"
          action="$form_action"
          method="POST"
          enctype="multipart/form-data"
          use:enhance
        >
        $form_title
        <input type="hidden" name="validation" value={jsonState} />
        $gen_form
        $form_submit_button
        </form>

    };

    return $form;

}

sub get_input() {
    my ( $field_name, $field_type ) = @_;
    print "Sub input $field_type \n";
    if ( $field_type eq "text" ) {
        print "Creating text input.... \n";
        $input = qq{
          <div class="my-4 flex flex-col">
            <label for="name">$field_name</label>
            <input type="text" id="$field_name" bind:value={$field_name} name="$field_name" />
            {#if !formValidation?.success}
              <!-- content here -->
              <p class="text-red-600 mt-2">{formValidation?.errors.get("$field_name")}</p>
            {/if}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "textarea" ) {
        print "Creating textarea.... \n";
        $input = qq{
          <div class="my-4 flex flex-col">
            <label for="$field_name">$field_name</label>
            <textarea name="$field_name" id="$field_name" bind:value={$field_name}
            ></textarea>
            {#if !formValidation?.success}
              <!-- content here -->
              <p class="text-red-600 mt-2">
                {formValidation?.errors.get("$field_name")}
              </p>
            {/if}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "file" ) {
        print "Creating file input.... \n";
        $input = qq{
            <input value={uuid} type="hidden" name="uuid" />
            <FileInputUploader {accept} {uuid} {uploadDoneCallBack} label="$type_name Poster" />

        };
        return $input;
    }
    else {
        print "Unknown input type";

    }
}
