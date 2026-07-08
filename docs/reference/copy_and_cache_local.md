# Copy local font files to cache and create a cache entry

Copies each local font file into the cache directory, creates a
[`CacheEntry()`](http://guillaume-noblet.com/AddFonts/reference/CacheEntry.md)
with symbolic keys and source `"file"`, writes the entry to the cache,
and returns it.

## Usage

``` r
copy_and_cache_local(name, family_name, variants, cache_dir = NULL)
```

## Arguments

- name:

  (`character(1)`) Font name (used as the family component of cache
  filenames).

- family_name:

  (`character(1)`) Family name under which to register the font.

- variants:

  (`list`) Named list mapping symbolic variant keys to absolute file
  paths. Names must be a subset of
  `c("regular", "italic", "bold", "bolditalic")`. At minimum,
  `"regular"` must be present.

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL).

## Value

(`CacheEntry | NULL`) Cache entry with copied variants, or `NULL` if the
regular variant could not be copied.
