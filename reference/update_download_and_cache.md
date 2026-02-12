# Download missing weights and update an existing cache entry

Downloads missing font weights and updates the cache entry. Does NOT
register the font - use register_from_cache() after this.

## Usage

``` r
update_download_and_cache(
  entry,
  provider,
  name,
  family_name,
  missing_weights,
  subset = "latin",
  cache_dir = NULL,
  cel = NULL
)
```

## Arguments

- entry:

  (`CacheEntry`) Existing cache entry to update.

- provider:

  (`FontProvider`) Provider object used for downloads.

- name:

  (`character(1)`) Font name at the provider.

- family_name:

  (`character(1)`) Family name for the font.

- missing_weights:

  (`numeric`) Vector of weights to download and add to cache.

- subset:

  (`character(1)`) Glyph subset to request (default: "latin").

- cache_dir:

  (`character | NULL`) Cache directory to use.

- cel:

  (`CacheEntryList`) Current cache entry list to update.

## Value

(`CacheEntry | NULL`) Updated cache entry with new weights (NOT
registered), or NULL on failure.
