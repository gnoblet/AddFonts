# Route add_font() for provider = "url" (direct download)

Handles the cache-check → download → register cycle when the user
supplies `provider = "url"`. Uses source key `"url"` in the cache index.

## Usage

``` r
.add_font_direct_url(name, family_name, variants, cache_dir)
```

## Arguments

- name:

  (`character(1)`) Font name (used as the family component of cache
  filenames).

- family_name:

  (`character(1)`) Family name to register the font under.

- variants:

  (`list`) Named list mapping symbolic variant keys to full download
  URLs.

- cache_dir:

  (`character(1)`) Cache directory path.

## Value

(`list`) Invisibly, a named list of local file paths for all registered
variants.
