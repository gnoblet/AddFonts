# Download font files for specified weights

Downloads normal and italic variants for each weight and returns a named
list with weight-based keys.

## Usage

``` r
download_weights(provider, name, weights, subset, cache_dir, quiet = TRUE)
```

## Arguments

- provider:

  (`FontProvider`) Provider object used for downloads.

- name:

  (`character(1)`) Font name at the provider.

- weights:

  (`numeric`) Vector of weights to download.

- subset:

  (`character(1)`) Glyph subset to request.

- cache_dir:

  (`character(1)`) Cache directory to use.

- quiet:

  (`logical(1)`) Whether to suppress download messages (default: TRUE).

## Value

(`list`) Named list where names are weight identifiers (e.g., "400",
"700italic") and values are file paths.
