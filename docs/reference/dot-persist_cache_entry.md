# Build a CacheEntry, persist the cache index, and return the entry

Constructs a
[`CacheMeta()`](http://guillaume-noblet.com/AddFonts/reference/CacheMeta.md)
and a
[`CacheEntry()`](http://guillaume-noblet.com/AddFonts/reference/CacheEntry.md),
upserts the entry into the on-disk cache index via `cache_read_safe()`,
[`cache_set()`](http://guillaume-noblet.com/AddFonts/reference/cache_set.md),
and
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md),
then returns the new entry. This is the shared persist tail used by all
download/copy orchestrators.

## Usage

``` r
.persist_cache_entry(
  source,
  family_name,
  files_entry,
  cache_dir,
  failed_keys = character(0)
)
```

## Arguments

- source:

  (`character(1)`) Provider source identifier (e.g. `"bunny"`, `"file"`,
  `"url"`).

- family_name:

  (`character(1)`) Family identifier to register the entry under.

- files_entry:

  (`list`) Named list of variant-key to local file path mappings.

- cache_dir:

  (`character(1)`) Path to the cache directory.

- failed_keys:

  (`character(0+)`) A character vector of keys that were requested but
  failed to download. Empty if all requested keys were successfully
  downloaded. (default: character(0))

## Value

(`CacheEntry`) The newly created cache entry.
