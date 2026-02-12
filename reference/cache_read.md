# Read cache entry from disk

Read cache entry from disk

## Usage

``` r
cache_read(cache_dir)
```

## Arguments

- cache_dir:

  (`character | NULL`) Cache directory to use. Use
  [`get_cache_dir()`](http://guillaume-noblet.com/AddFonts/reference/get_cache_dir.md)
  to get the default cache directory.

## Value

(`CacheEntryList`) The cache index as a if found and valid.

## See also

Other cache:
[`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md),
[`cache_get()`](http://guillaume-noblet.com/AddFonts/reference/cache_get.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md),
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
