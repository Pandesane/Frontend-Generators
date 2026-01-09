package Svelte::Funcs;

use strict;
use diagnostics;

use base "Exporter";

our @EXPORT_OK = qw(
  gen_edit_form
  gen_edit_input
  push_data_to_file
  generate_divs
  generate_form_data
  gen_schema_fields
);

sub gen_edit_form {

    # my ($form_type) = @_;
    my ( $file_name, $resource_name_import, $resource_name_singular,
        $resource_name, @fields )
      = @_;

    my $form_heading      = "Edit $resource_name_singular";
    my $form_submit_label = "Save";
    my $form_action       = "?/update";

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

    my $form = qq{
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

sub get_edit_input {
    my ( $field_name, $field_type, $resource_name_singular, $resource_name ) =
      @_;

    if ( $field_type eq "text" ) {
        print "Creating text input.... \n";
        my $input = qq{
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
        my $input = qq{
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
        my $input = qq{
            <input value={uuid} type="hidden" name="uuid" />
            <FileInputUploader {accept} {uuid} {uploadDoneCallBack} label="$resource_name Poster" />

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

    my ( $resource_name_import, $resource_name_singular, @fields ) = @_;

    my $form_heading      = "Create New  $resource_name_singular";
    my $form_submit_label = "Create";
    my $form_action       = "?/create";

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

    my $form = qq{
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
    print "Sub input $field_type \n";
    if ( $field_type eq "text" ) {
        print "Creating text input.... \n";
        my $input = qq{
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
        my $input = qq{
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
        my $input = qq{
            <input value={uuid} type="hidden" name="uuid" />
            <FileInputUploader {accept} {uuid} {uploadDoneCallBack} label="File Name" />

        };
        return $input;
    }
    else {
        print "Unknown input type";

    }
}

1;
