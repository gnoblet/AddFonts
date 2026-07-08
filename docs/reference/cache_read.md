# Read cache entry from disk

Read cache entry from disk

## Usage

``` r
cache_read(cache_dir)

## S7 method for class <character>
cache_read(cache_dir)
```

## Arguments

- cache_dir:

  (`character(1)`) Cache directory path. Must not be NULL. Use
  `cache_read_safe()` for a NULL-tolerant variant that returns an empty
  index on error.

## Value

(`CacheEntryList`) The cache index as a CacheEntryList if found and
valid.

## See also

Other cache:
[`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md),
[`cache_get()`](http://guillaume-noblet.com/AddFonts/reference/cache_get.md),
[`cache_get_variants()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_variants.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md),
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
