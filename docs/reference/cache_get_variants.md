# Check which symbolic variant keys are present in a CacheEntry

Used for file-based providers whose `CacheMeta@files` uses the key
`"regular"`, `"italic"`, `"bold"`, `"bolditalic"` instead of numeric
weight strings.

## Usage

``` r
cache_get_variants(entry, variants)

## S7 method for class <AddFonts::CacheEntry>
cache_get_variants(entry, variants)
```

## Arguments

- entry:

  (`CacheEntry`) The cache entry to inspect.

- variants:

  (`character`) Character vector of symbolic variant names to check.

## Value

(`lgl`) Named logical vector indicating which variants are cached.

## See also

Other cache:
[`cache_clean()`](http://guillaume-noblet.com/AddFonts/reference/cache_clean.md),
[`cache_get()`](http://guillaume-noblet.com/AddFonts/reference/cache_get.md),
[`cache_get_weights()`](http://guillaume-noblet.com/AddFonts/reference/cache_get_weights.md),
[`cache_read()`](http://guillaume-noblet.com/AddFonts/reference/cache_read.md),
[`cache_remove()`](http://guillaume-noblet.com/AddFonts/reference/cache_remove.md),
[`cache_write()`](http://guillaume-noblet.com/AddFonts/reference/cache_write.md)
