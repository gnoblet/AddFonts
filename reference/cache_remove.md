# Delete entry from cache

Delete entry from cache

## Usage

``` r
cache_remove(x, families = NULL, remove_files = TRUE, cache_dir = NULL)
```

## Arguments

- x:

  (`CacheEntryList`) The CacheEntryList object to modify.

- families:

  (`character | NULL`) The font families to delete. If NULL, all entries
  are deleted.

- remove_files:

  (`logical(1)`) If `TRUE` attempt to delete files referenced by removed
  entries (default: TRUE).

- cache_dir:

  (`character(1) | NULL`) The cache directory to delete from. If NULL,
  the default cache directory is used.

## Value

(`CacheEntryList`) The modified CacheEntryList with the specified
entries removed.

## See also

Other cache:
[`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md),
[`cache_get()`](http://guillaume-noblet.com/AddFonts/reference/cache_get.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_read()`](http://guillaume-noblet.com/AddFonts/reference/cache_read.md),
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
