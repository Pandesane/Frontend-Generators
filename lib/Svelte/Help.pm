package Svelte::Help;

use strict;
use diagnostics;

use base "Exporter";

our @EXPORT_OK = qw(gen_help);

sub gen_help {
    my $help = q{
      ## Help

    ``` $ svelte gen.resource[:layout] resource [(field_type):(input_type) ...] ```

    ``` $ svelte gen.resource:app_layout shops name:text description:textarea file:file ```

    layout -> app_layout Note: Can only allow one parent layout
    resource -> shops Note: Resource must end with an s
    fields -> name:text description:textarea file:file

    OR: with custom path name and file name
    Note correct error with file_name not used its just generated from path_name

    ``` $ svelte gen.resource[:layout] path_name:file_name [(field_type):(input_type) ...] ```

    ``` $ svelte gen.resource:app_layout productAds:ProductAds name:text description:textarea file:file ```

    layout -> app_layout Note: Can only allow one parent layout
    path_name -> productAds Note: path_name must end with an s
    file_name -> ProductAds Note: file_name must end with an s
    fields -> name:text description:textarea file:file

    Fields
    (field_type):(input_type)
    e.g. From above
    name:text -> field_type = name and input_type = text


    ``` $ svelte (help | -h | --help) ```
    Outputs help information


  };

    print $help;

}


1;