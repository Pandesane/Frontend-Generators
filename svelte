#!/usr/bin/perl

# svelte gen.resource product name:text description:textarea file:file

# Run formatter for all files in the project

use strict;
use warnings;
use diagnostics;

use lib "lib";
use Svelte::Help;
use Svelte::Routes::Index;
use Svelte::Routes::New;
use Svelte::Routes::Slug::Index;
use Svelte::Routes::Slug::Edit;
use Svelte::Schema;
use Svelte::Api;
use Svelte::Interface;
use Svelte::Components::Component;
use Svelte::Components::Index;
use Svelte::Components::New;
use Svelte::Components::Edit;
use Svelte::Components::Actions;

my $type      = $ARGV[0];
my $type_name = $ARGV[1];
my @fields    = @ARGV[ 2 .. ( scalar(@ARGV) - 1 ) ];
print "Fields got: @fields \n ";

# Resouce name ie products and product

my $resource_name = lc($type_name);
my $resource_name_singular =
  substr( $resource_name, 0, length($resource_name) - 1 );
my $resource_name_import          = ucfirst($resource_name);
my $resource_name_singular_import = ucfirst($resource_name_singular);

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
my $dev              = 1;
my $routes_base_path = "gen/src/routes/$resource_name";
my $lib_base_path    = "gen/src/lib/";

# Default dirs for generated files
if ( $dev == 1 ) {
    $routes_base_path = "gen/src/routes/$resource_name";
    $lib_base_path    = "gen/src/lib/";

}
else {
    $routes_base_path = "src/routes/$resource_name";
    $lib_base_path    = "src/lib/";
}

if ( $type eq "help" || $type eq "--help" || $type eq "-h" ) {
    Svelte::Help::gen_help();
}
elsif ( $type eq "gen.resource" || $type =~ "gen.resource:" ) {

    my ( $_ignore, $layout ) = split( ":", $type );

    if ($layout) {
        print("Got layout of file: $layout \n");
        if ( $dev == 1 ) {
            $routes_base_path = "gen/src/routes/($layout)/$resource_name";

        }
        else {
            $routes_base_path = "src/routes/($layout)/$resource_name";

        }
    }
    if ( -d $routes_base_path ) {
        print "Resource already created. \n";
        exit("Resource already created.");
    }
    print "Generating resource: $resource_name \n";

    # Make resource directories
    `mkdir -p "$routes_base_path"`;
    `mkdir -p "$routes_base_path/new"`;
    `mkdir -p "$routes_base_path/[slug]"`;
    `mkdir -p "$routes_base_path/[slug]/edit"`;

    # `mkdir -p $lib_base_path`;
    # `mkdir -p $lib_base_path/api/`;
    # `mkdir -p $lib_base_path/schemas/`;
    # `mkdir -p $lib_base_path/interfaces/`;

    # # Make index files
    my $index_path = $routes_base_path;
    `touch "$index_path/+page.svelte"`;
    Svelte::Routes::Index::gen_index_page_svelte( "$index_path/+page.svelte",
        $resource_name_import,   $resource_name,
        $resource_name_singular, @fields );

    `touch "$index_path/+page.server.ts"`;
    Svelte::Routes::Index::gen_index_page_ts( "$index_path/+page.server.ts",
        $resource_name_import, $resource_name, @fields );

    # # Make new files
    my $new_path = "$routes_base_path/new";
    `touch "$new_path/+page.svelte"`;
    Svelte::Routes::New::gen_new_page_svelte(
        "$new_path/+page.svelte", $resource_name_import,
        $resource_name_singular,  @fields
    );

    `touch "$new_path/+page.server.ts"`;
    Svelte::Routes::New::gen_new_page_server( "$new_path/+page.server.ts",
        $resource_name_import, $resource_name, @fields );

    # # Make slug layout file
    my $slug_path = "$routes_base_path/[slug]";
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
    my $edit_path = "$routes_base_path/[slug]/edit";
    `touch "$edit_path/+page.svelte"`;
    Svelte::Routes::Slug::Edit::gen_slug_edit_page_svelte(
        "$edit_path/+page.svelte", $resource_name_import,
        $resource_name_singular,   $resource_name, @fields );

    `touch "$edit_path/+page.server.ts"`;
    Svelte::Routes::Slug::Edit::gen_slug_edit_page_ts(
        "$edit_path/+page.server.ts", $resource_name_import, $resource_name );

    gen_api_interface_schema()

    # TODO: Run prettier formatter

}
elsif ( $type =~ "gen.api" ) {

# DOCS
# svelte gen.api resourcename_url:resource_name_plural_caps [fields...]
# svelte gen.api liveShops:LiveShops  topic:text description:textarea active_watchers:text
# resourcename_url and resource_name_capital must be in plural ie liveShops:LiveShops
# svelte gen.api resourcename [fields...]
# svelte gen.api carts user_id:text cart_product_id:text
# resourcename must be in plural ie carts

    print "Generating API \n";

    gen_api_interface_schema();
}
elsif ( $type eq "gen.resource.component" ) {

    # Generate API files, Schema, Interface
    gen_api_interface_schema();

    print "Generating resource component \n";
    my $component_base_path =
      "${lib_base_path}components/resource/$resource_name";

    if ( -d $component_base_path ) {
        print "Resource already created. \n";
        exit(2);
    }

    `mkdir  -p "$component_base_path"`;

    # Component
    my $component_file_path =
      "$component_base_path/${resource_name_import}Component.svelte";

    `touch "$component_file_path"`;
    Svelte::Components::Component::gen_component( $component_file_path,
        $resource_name, $resource_name_import, $resource_name_singular,
        $resource_name_singular_import, @fields );

    # Index
    my $component_index_file_path =
      "$component_base_path/${resource_name_import}Index.svelte";

    `touch "$component_file_path"`;

    Svelte::Components::Index::gen_component_index( $component_index_file_path,
        $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields );

    # New
    my $component_new_file_path =
      "$component_base_path/${resource_name_import}NewForm.svelte";

    `touch "$component_new_file_path"`;

    Svelte::Components::New::gen_component_new_form( $component_new_file_path,
        $resource_name, $resource_name_import,
        $resource_name_singular, $resource_name_singular_import, @fields );

    # Edit
    my $component_edit_file_path =
      "$component_base_path/${resource_name_import}EditForm.svelte";

    `touch "$component_edit_file_path"`;

    Svelte::Components::Edit::gen_component_edit_form(
        $component_edit_file_path, $resource_name, $resource_name_import,
        $resource_name_singular,   $resource_name_singular_import, @fields );

    # Actions
    my $component_actions_file_path =
      "$component_base_path/${resource_name_import}Actions.txt";

    `touch "$component_actions_file_path"`;
    Svelte::Components::Actions::gen_component_actions(
        $component_actions_file_path, $resource_name_import,
        $resource_name_singular );

}

sub gen_api_interface_schema {

    `mkdir -p $lib_base_path`;
    `mkdir -p $lib_base_path/api/`;
    `mkdir -p $lib_base_path/schemas/`;
    `mkdir -p $lib_base_path/interfaces/`;

    # Resource schema
    my $schema_path =
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
    my $api_path = "$lib_base_path/api/${resource_name_import}API.ts";
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
    my $interface_path =
      "$lib_base_path/interfaces/I${resource_name_singular_import}.ts";
    if ( !( -f "$interface_path" ) ) {
        `touch "$interface_path"`;
        Svelte::Interface::gen_resource_interface( "$interface_path",
            $resource_name_singular_import, @fields );

    }
    else {
        print "File Already exists \n";
    }

}
