# Download direct-URL font variants and add to cache

Downloads each variant from a direct URL, creates a
[`CacheEntry()`](http://guillaume-noblet.com/AddFonts/reference/CacheEntry.md)
with symbolic keys and source `"url"`, writes the entry to the cache,
and returns it.

## Usage

``` r
download_and_cache_url(name, family_name, variants, cache_dir = NULL)
```

## Arguments

- name:

  (`character(1)`) Font name (used as the family component of cache
  filenames).

- family_name:

  (`character(1)`) Family name under which to register the font.

- variants:

  (`list`) Named list mapping symbolic variant keys to full URLs. Names
  must be a subset of `c("regular", "italic", "bold", "bolditalic")`. At
  minimum, `"regular"` must be present.

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL).

## Value

(`CacheEntry | NULL`) Cache entry with downloaded variants, or `NULL` if
the regular variant could not be downloaded.
