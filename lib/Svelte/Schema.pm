package Svelte::Schema;

use strict;
use diagnostics;

use base "Exporter";

use lib "lib";
use Svelte::Funcs;

our @EXPORT_OK = qw(gen_resource_schema);

sub gen_schema_fields {
    my (@fields) = @_;
    my $gen_fields = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type ne "file" ) {
            if ( $field_type eq "textarea" ) {
                $gen_fields .= qq{
            $field: v.pipe(v.string(), v.nonEmpty("$field cannot be blank."), v.minLength(15, "$field must be at least 15 characters long")),
            };
            } else {

               $gen_fields .= qq{
                 $field: v.pipe(v.string(), v.nonEmpty("$field can't be blank."), v.minLength(5, "$field must be at least 5 characters long")),
            };
            }
        }

    }
    $gen_fields .= qq{
       //id: v.union([v.string(), v.number()]),
       // relation_id: v.union([v.string(), v.number()]),

   };
    return $gen_fields;
}

sub gen_resource_schema {
    my ( $file_name, $resource_name_singular_import,
        $resource_name_import, $resource_name, @fields )
      = @_;
    my $gen_fields = gen_schema_fields(@fields);
    my $template   = qq{
     import * as z from "zod";

      export const ${resource_name_singular_import}SchemaMap: Record<string, z.ZodString> = {
        $gen_fields
      }
      const ${resource_name_singular_import}Schema = z.object(${resource_name_singular_import}SchemaMap);

      export default ${resource_name_singular_import}Schema
  };

    Svelte::Funcs::push_data_to_file( $file_name, $template );

}

1;
