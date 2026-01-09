package Svelte::Schema;

use strict;
use diagnostics;

use base "Exporter";

our @EXPORT_OK = qw(gen_resource_schema);

sub gen_resource_schema {
    my ( $file_name, $resource_name_singular_import,
        $resource_name_import, $resource_name )
      = @_;
    my $gen_fields = gen_schema_fields();
    my $template   = qq{
     import * as z from "zod";

      export const ${resource_name_singular_import}SchemaMap: Record<string, z.ZodString> = {
        $gen_fields
      }
      const ${resource_name_singular_import}Schema = z.object(${resource_name_singular_import}SchemaMap);

      export default ${resource_name_singular_import}Schema
  };

    push_data_to_file( $file_name, $template );

}

1;
