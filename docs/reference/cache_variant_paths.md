# Compute paths used for caching provider artifacts and any conversion intermediate files.

Compute paths used for caching provider artifacts and any conversion
intermediate files.

## Usage

``` r
cache_variant_paths(provider, family, weight, style, subset, cache_dir = NULL)
```

## Arguments

- provider:

  (`FontProvider`) Provider object with source and optional conversion
  info.

- family:

  (`character(1)`) Family identifier.

- weight:

  (`integer(1)`) Font weight.

- style:

  (`character(1)`) Style string (e.g. "normal", "italic").

- subset:

  (`character(1)`) Glyph subset identifier.

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL)

## Value

(`list`) A list with elements `to_convert` (path or NULL) and `ttf`
(path).
