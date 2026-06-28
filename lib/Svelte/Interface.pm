package Svelte::Interface;

use strict;
use diagnostics;

use base "Exporter";
# use lib "lib";
use lib "lib", "/home/pande/bin/lib";

use Svelte::Funcs;
use Regex::Regex;
use Regex::RegexHelpers;

our @EXPORT_OK = qw(gen_resource_interface);

sub gen_resource_interface {
    my ( $file_name, $resource_name_singular_import, @fields ) = @_;

    my $gen_fields = "";
    foreach my $i (@fields) {
        my ( $field, $field_type ) = split( ":", $i );
        if ( $field_type ne "file" ) {
            $gen_fields .= qq{
            $field: string,
        };
        }

    }



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

my $template_filename = "/home/pande/bin/lib/" . "Svelte/Templates/interface.txt";
    # my $template_filename = "./lib/Svelte/Templates/interface.txt";

    my $template_data =
      Regex::RegexHelpers::gen_from_regex_template( $template_filename,
        @match_expressions );


    # print $template_data;


    Svelte::Funcs::push_data_to_file( $file_name, $template_data );

}

1;
