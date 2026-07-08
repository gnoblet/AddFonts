# Validate a cache entry and register the font with sysfonts if the required files exist. Returns the prepared `files` list or `NULL` when registration cannot proceed.

This is the ONLY function that calls sysfonts::font_add(). It does not
print success messages - callers should handle user feedback.

## Usage

``` r
register_from_cache(entry, regular.wt = 400, bold.wt = 700)
```

## Arguments

- entry:

  (`CacheEntry`) Cache entry object with family and metadata.

- regular.wt:

  (`numeric(1)`) Regular weight to use for regular and italic variants
  (default: 400).

- bold.wt:

  (`numeric(1)`) Bold weight to use for bold and bolditalic variants
  (default: 700).

## Value

(`list | NULL`) Prepared `files` list (with `regular`, `italic`, `bold`,
`bolditalic`) or `NULL`.
