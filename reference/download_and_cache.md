# Download font variants and add to cache

Downloads font files for requested weights, creates a cache entry, and
writes to cache. Does NOT register the font - caller should use
register_from_cache() for that.

## Usage

``` r
download_and_cache(
  provider,
  name,
  font_id,
  family_name,
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin",
  cache_dir = NULL
)
```

## Arguments

- provider:

  (`FontProvider`) Provider object used for downloads.

- name:

  (`character(1)`) Font name at the provider.

- font_id:

  (`character(1)`) Filesystem-safe font id.

- family_name:

  (`character(1)`) Family name for the font.

- regular.wt:

  (`integer(1)`) Regular weight to fetch (default: 400)

- bold.wt:

  (`integer(1)`) Bold weight to fetch (default: 700)

- subset:

  (`character(1)`) Glyph subset to request (default: "latin")

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL)

## Value

(`CacheEntry | NULL`) Cache entry with downloaded fonts, or `NULL` on
failure.
