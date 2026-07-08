# Route add_font() for a weight-based provider

Handles the full cache-check → optional partial update-download-register
cycle for `FontProviderWeight` providers.

## Usage

``` r
.add_font_weight(
  provider_obj,
  name,
  family_name,
  regular.wt,
  bold.wt,
  subset,
  cache_dir
)
```

## Arguments

- provider_obj:

  (`FontProviderWeight`) Weight-based provider object.

- name:

  (`character(1)`) Font name at the provider.

- family_name:

  (`character(1)`) Family name to register the font under.

- regular.wt:

  (`numeric(1)`) Regular weight to request.

- bold.wt:

  (`numeric(1)`) Bold weight to request.

- subset:

  (`character(1)`) Glyph subset to request.

- cache_dir:

  (`character(1)`) Cache directory path.

## Value

(`list`) Invisibly, a named list of local file paths for all registered
variants.
