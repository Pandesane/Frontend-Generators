#!/usr/bin/perl

# svelte gen.resource product name:text description:textarea file:file

# Run formatter for all files in the project

# use strict;
# use warnings;
# use diagnostics;

use lib "lib";
use Svelte::Help;
use Svelte::Routes::Index;
use Svelte::Routes::New;
use Svelte::Routes::Slug::Index;
use Svelte::Routes::Slug::Edit;
use Svelte::Schema;
use Svelte::Api;
use Svelte::Interface;

$type      = $ARGV[0];
$type_name = $ARGV[1];
@fields    = @ARGV[ 2 .. ( scalar(@ARGV) - 1 ) ];
print "Fields got: @fields \n ";

# Resouce name ie products and product

$resource_name = lc($type_name);
$resource_name_singular =
  substr( $resource_name, 0, length($resource_name) - 1 );
$resource_name_import          = ucfirst($resource_name);
$resource_name_singular_import = ucfirst($resource_name_singular);

if ( $type_name =~ /(\b.*):(\b.*)/ ) {
    print("True $type_name $1  :   $2\n");
    $resource_name = $1;
    $resource_name_singular =
      substr( $resource_name, 0, length($resource_name) - 1 );
    $resource_name_import          = ucfirst($resource_name);
    $resource_name_singular_import = ucfirst($resource_name_singular);
}

# E.g categories
if ( $type_name =~ /(\b.*)ies/ ) {
    print("True $type_name $1  :   $2\n");

    # $resource_name = $1;
    $resource_name_singular        = "${1}y";
    $resource_name_import          = ucfirst($resource_name);
    $resource_name_singular_import = ucfirst($resource_name_singular);
}

print("Resource Name: $resource_name \n");

if ( $type eq "help" || $type eq "--help" || $type eq "-h" ) {
    Svelte::Help::gen_help();
}
elsif ( $type =~ "gen.resource" ) {

    my ( $_ignore, $layout ) = split( ":", $type );
    print("Got layout of file: $layout \n");
    $routes_base_path = "gen/src/routes/$resource_name";

    if ($layout) {
        $routes_base_path = "gen/src/routes/($layout)/$resource_name";
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

    $lib_base_path = "gen/src/lib/";
    `mkdir -p $lib_base_path`;
    `mkdir -p $lib_base_path/api/`;
    `mkdir -p $lib_base_path/schemas/`;
    `mkdir -p $lib_base_path/interfaces/`;

    # # Make index files
    $index_path = $routes_base_path;
    `touch "$index_path/+page.svelte"`;

    # gen_index_page_svelte("$index_path/+page.svelte");
    Svelte::Routes::Index::gen_index_page_svelte( "$index_path/+page.svelte",
        $resource_name_import,   $resource_name,
        $resource_name_singular, @fields );

    `touch "$index_path/+page.server.ts"`;
    Svelte::Routes::Index::gen_index_page_ts( "$index_path/+page.server.ts",
        $resource_name_import, $resource_name, @fields );

    # # Make new files
    $new_path = "$routes_base_path/new";
    `touch "$new_path/+page.svelte"`;
    Svelte::Routes::New::gen_new_page_svelte(
        "$new_path/+page.svelte", $resource_name_import,
        $resource_name_singular,  @fields
    );

    `touch "$new_path/+page.server.ts"`;
    Svelte::Routes::New::gen_new_page_server( "$new_path/+page.server.ts",
        $resource_name_import, $resource_name, @fields );

    # # Make slug layout file
    $slug_path = "$routes_base_path/[slug]";
    `touch "$slug_path/+layout.server.ts"`;
    Svelte::Routes::Slug::Index::gen_slug_layout_server_ts(
        "$slug_path/+layout.server.ts",
        $resource_name_import,          $resource_name_singular,
        $resource_name_singular_import, @fields );

    # # Make show files
    `touch "$slug_path/+page.svelte"`;
    Svelte::Routes::Slug::Index::gen_slug_page_svelte(
        "$slug_path/+page.svelte", $resource_name_import,
        $resource_name_singular,   $resource_name_singular_import,
        $resource_name,            @fields );

    `touch "$slug_path/+page.server.ts"`;
    Svelte::Routes::Slug::Index::gen_slug_page_ts( "$slug_path/+page.server.ts",
        $resource_name_import, $resource_name );

    # # Make edit files
    $edit_path = "$routes_base_path/[slug]/edit";
    `touch "$edit_path/+page.svelte"`;

    # $form_title        = "Edit $resource_name_singular";
    # $form_submit_label = "Save";
    # $form_action       = "?/update";
    Svelte::Routes::Slug::Edit::gen_slug_edit_page_svelte(
        "$edit_path/+page.svelte", $resource_name_import,
        $resource_name_singular,   $resource_name, @fields );

    `touch "$edit_path/+page.server.ts"`;
    Svelte::Routes::Slug::Edit::gen_slug_edit_page_ts(
        "$edit_path/+page.server.ts", $resource_name_import, $resource_name );

    # Resource schema
    $schema_path =
      "$lib_base_path/schemas/${resource_name_singular_import}Schema.ts";
    if ( !( -f "$schema_path" ) ) {
        `touch "$schema_path"`;
        Svelte::Schema::gen_resource_schema( "$schema_path",
            $resource_name_singular_import,
            $resource_name_import, $resource_name, @fields );

    }
    else {
        print "File Already exists \n";
    }

    # Resource API
    $api_path = "$lib_base_path/api/${resource_name_import}API.ts";
    if ( !( -f "$api_path" ) ) {
        `touch "$api_path"`;
        Svelte::Api::gen_resource_api( "$api_path",
            $resource_name_singular_import,
            $resource_name_import, $resource_name );

    }
    else {
        print "File Already exists \n";
    }

    # Resource interface
    $interface_path =
      "$lib_base_path/interfaces/I${resource_name_singular_import}.ts";
    if ( !( -f "$interface_path" ) ) {
        `touch "$interface_path"`;
        Svelte::Interface::gen_resource_interface( "$interface_path",
            $resource_name_singular_import, @fields );

    }
    else {
        print "File Already exists \n";
    }

    # TODO: Run prettier formatter

}
