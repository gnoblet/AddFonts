# Route add_font() for a file-based provider

Handles the cache-check → download → register cycle for
`FontProviderFile` providers using symbolic variant keys.

## Usage

``` r
.add_font_file(provider_obj, name, family_name, variants, cache_dir)
```

## Arguments

- provider_obj:

  (`FontProviderFile`) File-based provider object.

- name:

  (`character(1)`) Font name at the provider (used as `{family}` in the
  URL template).

- family_name:

  (`character(1)`) Family name to register the font under.

- variants:

  (`list`) Named list mapping symbolic variant keys to filename stems.

- cache_dir:

  (`character(1)`) Cache directory path.

## Value

(`list`) Invisibly, a named list of local file paths for all registered
variants.
