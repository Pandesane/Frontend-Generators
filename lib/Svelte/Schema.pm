package Svelte::Schema;

use strict;
use diagnostics;

use base "Exporter";

# use lib "lib";
use lib "lib", "/home/pande/bin/lib";

use Svelte::Funcs;
use Regex::Regex;
use Regex::RegexHelpers;

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
            }
            else {

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
    my $gen_fields        = gen_schema_fields(@fields);
    my @match_expressions = (
        Regex::Regex->new(
            {
                regex => qr/\{resource_name_singular_import\}/,
                value => ${resource_name_singular_import}
            }
        ),
        Regex::Regex->new(
            {
                regex => qr/\{gen_fields\}/,
                value => ${gen_fields}
            }
        )

    );

# my $template_filename = "/home/pande/bin/lib/" . "Phoenix/Templates/schema_json_with_file.txt";
    my $template_filename = "./lib/Svelte/Templates/schema.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );

    # $template_data =~ s/\{gen_fields\}/$gen_fields/g;
    # print $template_data;

    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
