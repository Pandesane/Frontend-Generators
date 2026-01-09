package Svelte::Interface;

use strict;
use diagnostics;

use base "Exporter";

our @EXPORT_OK = qw(gen_resource_interface);

sub gen_resource_interface {
    my ( $file_name, $resource_name_singular_import,
        $resource_name_import, $resource_name, @fields )
      = @_;

    my $gen_fields = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type ne "file" ) {
            $gen_fields .= qq{
            $field: string,
        };
        }

    }

    my $template = qq{
        export default interface I$resource_name_singular_import {
          id: string,
          // create_at: string,
          // updated_at: string,
          $gen_fields
        }
    };

    push_data_to_file( $file_name, $template );

}

1;
