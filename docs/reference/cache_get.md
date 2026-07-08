# Get certain families from CacheEntryList

Get certain families from CacheEntryList

## Usage

``` r
cache_get(x, families = NULL, source = NULL, quiet = TRUE)

## S7 method for class <AddFonts::CacheEntryList>
cache_get(x, families = NULL, source = NULL, quiet = TRUE)
```

## Arguments

- x:

  (`CacheEntryList`) The CacheEntryList object to query.

- families:

  (`character vector`) The family names to retrieve.

- source:

  (`character(1) | NULL`) If provided, look up by exact compound
  `"{source}::{family}"` key (fast). If `NULL`, scan all entries and
  match on family name alone (default: NULL).

- quiet:

  (`logical(1)`) If TRUE, suppress informational messages (default:
  TRUE).

## Value

(`list`) A list of CacheEntry objects matching the specified families,
or NULL.

## See also

Other cache:
[`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md),
[`cache_get_variants()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_variants.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_read()`](http://guillaume-noblet.com/AddFonts/reference/cache_read.md),
[`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md),
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
