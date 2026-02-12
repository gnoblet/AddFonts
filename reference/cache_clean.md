# Clean cache entries

Remove entries from the cache, optionally unlinking referenced files.

## Usage

``` r
cache_clean(cache_dir = NULL, families = NULL, reset = FALSE, ...)
```

## Arguments

- cache_dir:

  (`NULL | character(1)`) Cache directory to use (default: NULL)

- families:

  (`character | NULL`) Character vector of family names to remove, or
  `NULL` to clear the whole cache (default: NULL)

- reset:

  (`logical(1)`) If TRUE, completely reset and clear the cache (default:
  FALSE).

- ...:

  (`anyD`) Additional arguments (currently unused).

## Value

(`character | NULL`) Invisibly returns character vector of removed
family names when deleting specific entries, or `NULL` when nothing
changed. Remove files by default.

## See also

Other cache:
[`cache_get()`](http://guillaume-noblet.com/AddFonts/reference/cache_get.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_read()`](http://guillaume-noblet.com/AddFonts/reference/cache_read.md),
[`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md),
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
