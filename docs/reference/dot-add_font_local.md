# Route add_font() for provider = "file" (local copies)

Handles the cache-check → copy → register cycle when the user supplies
`provider = "file"`. Uses source key `"file"` in the cache index.

## Usage

``` r
.add_font_local(name, family_name, variants, cache_dir)
```

## Arguments

- name:

  (`character(1)`) Font name (used as the family component of cache
  filenames).

- family_name:

  (`character(1)`) Family name to register the font under.

- variants:

  (`list`) Named list mapping symbolic variant keys to absolute local
  file paths.

- cache_dir:

  (`character(1)`) Cache directory path.

## Value

(`list`) Invisibly, a named list of local file paths for all registered
variants.
