package Svelte::Api;

use strict;
use diagnostics;

use base "Exporter";

our @EXPORT_OK = qw(gen_resource_api);

sub gen_resource_api {

    my ( $file_name, $resource_name_singular_import,
        $resource_name_import, $resource_name )
      = @_;
    my $template = qq{
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

1;
