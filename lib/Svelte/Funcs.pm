package Svelte::Funcs;

use strict;
use diagnostics;

use base "Exporter";

use lib "lib", "/home/pande/bin/lib";

use Regex::Regex;
use Regex::RegexHelpers;

our @EXPORT_OK = qw(
  gen_edit_form
  gen_edit_input
  push_data_to_file
  generate_divs
  generate_form_data
  gen_schema_fields
);

sub gen_edit_form {

    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name, @fields )
      = @_;

    my $form_heading      = "Edit $resource_name_singular";
    my $form_submit_label = "Save";

    my $form_title = qq{
    <p class="text-center">$form_heading</p>
    };

    my $has_file = 0;

    my $gen_form = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );

        my $input =
          get_edit_input( $field, $field_type, $resource_name_singular,
            $resource_name );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
        $gen_form .= $input;
    }

    my $form_submit_button = $has_file == 1
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

    my @match_expressions = (
        Regex::Regex->new(
            {
                regex => qr/\{resource_name_singular\}/,
                value => ${resource_name_singular}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{form_title\}/,
                value => ${form_title}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{gen_form\}/,
                value => ${gen_form}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{form_submit_button\}/,
                value => ${form_submit_button}
            }
        ),

    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/routes/edit_form.txt";

    my $form =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    return $form;
}

sub gen_component_edit_form {

    # my ($form_type) = @_;
    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name, @fields )
      = @_;

    my $form_heading      = "Edit $resource_name_singular";
    my $form_submit_label = "Save";

    my $form_title = qq{
    <p class="text-center">$form_heading</p>
    };

    my $has_file = 0;

    my $gen_form = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";

        # my $input = get_edit_input( $field, $field_type );
        my $input =
          get_component_edit_input( $field, $field_type,
            $resource_name_singular, $resource_name );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
        $gen_form .= $input;
    }

    my $form_submit_button = $has_file == 1
      ? qq{
      <button
        bind:this={submitBtn}
        class="w-full rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white
        transition hover:bg-blue-700 active:scale-[0.98]"
      >
        $form_submit_label
      </button>

      <p class="text-center text-xs text-slate-500">
        {formStatus}
      </p>

    }
      : qq{
     <button
        bind:this={submitBtn}
        class="w-full rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white
        transition hover:bg-blue-700 active:scale-[0.98]"
      >
        $form_submit_label
      </button>
     };

     my @match_expressions = (
        Regex::Regex->new(
            {
                regex => qr/\{form_title\}/,
                value => ${form_title}
            }
        ),

        Regex::Regex->new(
            {
                regex => qr/\{gen_form\}/,
                value => ${gen_form}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{form_submit_button\}/,
                value => ${form_submit_button}
            }
        ),

    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/components/edit_form.txt";

    my $form =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    return $form;
}

sub get_edit_input {
    my ( $field_name, $field_type, $resource_name_singular, $resource_name ) =
      @_;

    if ( $field_type eq "text" ) {
        my $input = qq{
          <div class="flex flex-col gap-1.5">
            <label for="$field_name" class="text-xs font-medium text-slate-600"> $field_name </label>

            <input
              id="$field_name"
              type="text"
              name="$field_name"
              value={${resource_name_singular}.$field_name}
              class="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm
              transition outline-none
              focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100"
            />

            {#each edit{resource_name_singular_import}Form.fields.$field_name.issues() as issue}
              <p class="text-xs text-red-500">
                {issue.message}
              </p>
            {/each}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "textarea" ) {
        my $input = qq{
          <div class="flex flex-col gap-1.5">
            <label for="$field_name" class="text-xs font-medium text-slate-600">$field_name</label>

            <textarea
              name="$field_name"
              id="$field_name"
              value={${resource_name_singular}.$field_name}
              class="h-28 resize-none rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm
              transition outline-none
              focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
            ></textarea>

            {#each edit{resource_name_singular_import}Form.fields.$field_name.issues() as issue}
              <p class="text-xs text-red-500">
                {issue.message}
              </p>
            {/each}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "file" ) {
        my $input = qq{
               <input value={uuid} type="hidden" name="uuid" />
              	<div class="space-y-2 rounded-xl border border-slate-200 bg-slate-50 p-4">
                  <p class="text-xs font-medium text-slate-600">File Name</p>

                  <FileInputUploader
                    {accept}
                    bind:uuid={uuid!}
                    {uploadDoneCallBack}
                    label="File Name"
                  />

                </div>

        };
        return $input;
    }
    else {
        print "Unknown input type";

    }
}

sub get_component_edit_input {
    my ( $field_name, $field_type, $resource_name_singular, $resource_name ) =
      @_;

    if ( $field_type eq "text" ) {
        my $input = qq{
          <div class="flex flex-col gap-1.5">
            <label for="$field_name" class="text-xs font-medium text-slate-600">$field_name</label>

            <input
              type="text"
              id="title"
              {...edit{resource_name_singular_import}Form.fields.$field_name.as('text')}
              value={${resource_name_singular}.$field_name}
              class="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm
              transition outline-none
              focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
            />

            {#each edit{resource_name_singular_import}Form.fields.$field_name.issues() as issue}
              <p class="text-xs text-red-500">
                {issue.message}
              </p>
            {/each}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "textarea" ) {
        my $input = qq{
          <div class="flex flex-col gap-1.5">
            <label for="$field_name" class="text-xs font-medium text-slate-600">$field_name</label>

            <textarea
              id="$field_name"
              {...edit{resource_name_singular_import}Form.fields.$field_name.as('text')}
              class="h-28 resize-none rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm
              transition outline-none
              focus:border-blue-500 focus:ring-2 focus:ring-blue-100">{${resource_name_singular}.$field_name}</textarea
            >

            {#each edit{resource_name_singular_import}Form.fields.$field_name.issues() as issue}
              <p class="text-xs text-red-500">
                {issue.message}
              </p>
            {/each}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "file" ) {
        my $input = qq{
            <input value={uuid} type="hidden" name="uuid" />
            <FileInputUploader
              bind:this={fileUploader}
            {accept}
              bind:uuid={uuid!}
             {uploadDoneCallBack}
             label="$resource_name Poster" />

        };
        return $input;
    }
    else {
        print "Unknown input type";

    }

}

sub push_data_to_file {
    my ( $filename, $data ) = @_;
    open my $fh, ">", $filename or die "Cannot open file $filename";
    print $fh "$data \n";
}

sub generate_divs {
    my ( $resource_name_singular, $prefix_data, @fields ) = @_;

    my $gen_divs = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type eq "file" ) {
            if ($prefix_data) {
                $gen_divs .= qq{
                   <!-- <div class="font-semibold mt-2">{data.$resource_name_singular.$field}</div> -->
                };

            }
            else {
                $gen_divs .= qq{
                  <!-- <div class="font-semibold mt-2">{$resource_name_singular.$field}</div> -->
                };
            }
        }
        else {
            if ($prefix_data) {
                $gen_divs .= qq{
                <div class="font-semibold mt-2">{data.$resource_name_singular.$field}</div>
            };

            }
            else {
                $gen_divs .= qq{
                <div class="font-semibold mt-2">{$resource_name_singular.$field}</div>
              };
            }

        }
    }

    return $gen_divs;
}

sub generate_form_data {

    my ( $resource_name_import, $resource_name_singular,
        $resource_name_singular_import, @fields )
      = @_;

    my $form_heading      = "Create New  $resource_name_singular";
    my $form_submit_label = "Create";

    my $gen_form   = "";
    my $form_title = qq{
    <p class="text-center">$form_heading</p>
    };

    my $has_file = 0;

    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";
        my $input = get_input( $field, $field_type );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
        $gen_form .= $input;
    }

    my $form_submit_button = $has_file == 1
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

    my @match_expressions = (
        Regex::Regex->new(
            {
                regex => qr/\{resource_name_singular_import\}/,
                value => ${resource_name_singular_import}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{form_title\}/,
                value => ${form_title}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{gen_form\}/,
                value => ${gen_form}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{form_submit_button\}/,
                value => ${form_submit_button}
            }
        ),

    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/routes/new_form.txt";

    my $form =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    return $form;

}

sub generate_form_component_data {

    my ( $resource_name_import, $resource_name_singular, @fields ) = @_;

    my $form_heading      = "Create New  $resource_name_singular";
    my $form_submit_label = "Create";

    my $gen_form   = "";
    my $form_title = qq{
    <p class="text-center">$form_heading</p>
    };

    my $has_file = 0;

    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        print "$field  $field_type \n";
        my $input = get_input( $field, $field_type );
        if ( $field_type eq "file" ) {
            $has_file = 1;
        }
        $gen_form .= $input;
    }

    my $form_submit_button = $has_file == 1
      ? qq{
      <button
        disabled
        bind:this={submitBtn}
        class="w-full rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white
        transition-all duration-200
        hover:bg-indigo-700 hover:shadow-sm
        active:scale-[0.98]
        disabled:cursor-not-allowed disabled:bg-slate-300 disabled:text-slate-500 disabled:shadow-none"
      >
        $form_submit_label
      </button>

      <p class="text-center text-xs text-slate-500">
        {formStatus}
      </p>
    }
      : qq{
        <button
          type="submit"
          class="w-full rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white
          transition-all duration-200
          hover:bg-blue-700 hover:shadow-sm
          active:scale-[0.98]
          disabled:cursor-not-allowed disabled:bg-slate-300 disabled:text-slate-500"
        >
          $form_submit_label
        </button>
     };

    my @match_expressions = (
        Regex::Regex->new(
            {
                regex => qr/\{form_title\}/,
                value => ${form_title}
            }
        ),

        Regex::Regex->new(
            {
                regex => qr/\{gen_form\}/,
                value => ${gen_form}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{form_submit_button\}/,
                value => ${form_submit_button}
            }
        ),

    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/routes/new_form.txt";

    my $form =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    return $form;

}

sub gen_schema_fields {
    my (@fields) = @_;
    my $gen_fields = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type ne "file" ) {
            $gen_fields .= qq{
            $field: z.string(),
        };
        }

    }
    return $gen_fields;
}

sub get_input {
    my ( $field_name, $field_type ) = @_;
    if ( $field_type eq "text" ) {
        my $input = qq{
          <div class="flex flex-col gap-1.5">
            <label for="$field_name" class="text-xs font-medium text-slate-600"> $field_name </label>

            <input
              id="$field_name"
              name="$field_name"
              type="text"
              class="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm
              transition outline-none
              focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100"
            />

            {#each createNew{resource_name_singular_import}Form.fields.$field_name.issues() as issue}
              <p class="text-xs text-red-500">
                {issue.message}
              </p>
            {/each}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "textarea" ) {
        print "Creating textarea.... \n";
        my $input = qq{
          <div class="flex flex-col gap-1.5">
            <label for="$field_name" class="text-xs font-medium text-slate-600">$field_name</label>

            <textarea
              id="$field_name"
              name="$field_name"
              class="h-28 resize-none rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm
              transition outline-none
              focus:border-blue-500 focus:ring-2 focus:ring-blue-100"
              placeholder="Placeholder..."
            ></textarea>

            {#each createNew{resource_name_singular_import}Form.fields.$field_name.issues() as issue}
              <p class="text-xs text-red-500">
                {issue.message}
              </p>
            {/each}
          </div>
        };
        return $input;
    }
    elsif ( $field_type eq "file" ) {
        my $input = qq{
                <input value={uuid} type="hidden" name="uuid" />
              	<div class="space-y-2 rounded-xl border border-slate-200 bg-slate-50 p-4">
                  <p class="text-xs font-medium text-slate-600">File Name</p>

                  <FileInputUploader
                    {accept}
                    bind:uuid={uuid!}
                    {uploadDoneCallBack}
                    label="File Name"
                  />

                </div>

        };
        return $input;
    }
    else {
        print "Unknown input type";

    }
}

1;
