# Get certain families from CacheEntryList

Get certain families from CacheEntryList

## Usage

``` r
cache_get(x, families = NULL, quiet = TRUE)
```

## Arguments

- x:

  (`CacheEntryList`) The CacheEntryList object to query.

- families:

  (`character vector`) The family names to retrieve.

- quiet:

  (`logical(1)`) If TRUE, suppress informational messages (default:
  TRUE).

## Value

(`list`) A list of CacheEntry objects matching the specified families.
If no families

## See also

Other cache:
[`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_read()`](http://guillaume-noblet.com/AddFonts/reference/cache_read.md),
[`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md),
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
