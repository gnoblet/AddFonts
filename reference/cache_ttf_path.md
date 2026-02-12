# Compute canonical cache path for a TTF file

Compute canonical cache path for a TTF file

## Usage

``` r
cache_ttf_path(source, font_id, subset, weight, style, cache_dir = NULL)
```

## Arguments

- source:

  (`character(1)`) Provider source identifier.

- font_id:

  (`character(1)`) Font id used for filenames.

- subset:

  (`character(1)`) Glyph subset identifier.

- weight:

  (`integer(1)`) Font weight.

- style:

  (`character(1)`) Style string (e.g. "normal", "italic").

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL)

## Value

(`character(1)`) Path to the cached `.ttf` file.
