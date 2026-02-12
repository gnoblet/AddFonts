# Write CacheEntryList to disk as JSON

Write CacheEntryList to disk as JSON

## Usage

``` r
cache_write(x, cache_dir = NULL, quiet = TRUE)
```

## Arguments

- x:

  (`CacheEntryList`) The CacheEntryList object to write to disk.

- cache_dir:

  (`character(1)`) The cache directory to write to (default: NULL).

- quiet:

  (`logical(1)`) Whether to suppress output messages (default: TRUE).

## Value

(`NULL`) Invisibly returns NULL.

## See also

Other cache:
[`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md),
[`cache_get()`](http://guillaume-noblet.com/AddFonts/reference/cache_get.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_read()`](http://guillaume-noblet.com/AddFonts/reference/cache_read.md),
[`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md)
