## SvelteKit Resource Generator

This is a sveltekit generator for scaffolding resources

Built using perl

## Requirements

Must have a svelte kit project
Uses zod for validation
Uses api endpoints to publish data to server

## Not yet for production but you can edit to your project needs

## Make sure to add this file dir to ur environment path

## Only Supported input types are: text, textarea and file implemented as custom svelte component

## Help

`$ svelte gen.resource[:layout] resource [(field_type):(input_type) ...]`

`$ svelte gen.resource:app_layout shops name:text description:textarea file:file`

layout -> app_layout Note: Can only allow one parent layout
resource -> shops Note: Resource must end with an s
fields -> name:text description:textarea file:file

OR: with custom path name and file name
Note correct error with file_name not used its just generated from path_name

`$ svelte gen.resource[:layout] path_name:file_name [(field_type):(input_type) ...]`

`$ svelte gen.resource:app_layout productAds:ProductAds name:text description:textarea file:file`

layout -> app_layout Note: Can only allow one parent layout
path_name -> productAds Note: path_name must end with an s
file_name -> ProductAds Note: file_name must end with an s
fields -> name:text description:textarea file:file

Fields
(field_type):(input_type)
e.g. From above
name:text -> field_type = name and input_type = text

# DOCS for Generation an api which contains the schema files, api files and interface files

# svelte gen.api resourcename_url:resource_name_plural_caps [fields...]

# svelte gen.api liveShops:LiveShops topic:text description:textarea active_watchers:text

# resourcename_url and resource_name_capital must be in plural ie liveShops:LiveShops

# svelte gen.api resourcename [fields...]

# svelte gen.api carts user_id:text cart_product_id:text

# resourcename must be in plural ie carts

`$ svelte (help | -h | --help)`
Outputs help information

## Phoenix Elixir API generator aka paj

# Syntax

paj gen.api:[has_file] context module [fields ...]
has_file -> boolean field generates files with acceptance of a file uploaded to the server

Example:
`$ paj gen.api ShopContext Product name description`

context -> ShopContext
module -> Product
fields -> [name, description]

OR:
paj gen.api:[has_file] context module:module_file_name [fields ...]

Example:
` paj gen.api ShopContext ProductAd:product_ad name:text description:textarea file:file`

context -> ShopContext
module -> ProductAd
module_file_name -> product_ad
fields -> [name, description]

## PAJ (paj) Help

# Run command

` $ paj (help | --help | -h)`
