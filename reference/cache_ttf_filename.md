# Compose canonical filename for a cached TTF

Compose canonical filename for a cached TTF

## Usage

``` r
cache_ttf_filename(source, font_id, subset, weight, style)
```

## Arguments

- source:

  (`character(1)`) Provider source identifier.

- font_id:

  (`character(1)`) Font id used to create a filesystem-safe filename.

- subset:

  (`character(1)`) Glyph subset identifier.

- weight:

  (`integer(1)`) Font weight.

- style:

  (`character(1)`) Style string (e.g. "normal", "italic").

## Value

(`character(1)`) Filename (not including the cache directory) for the
cached TTF.
