# S7-backed cache entry (CacheEntry)

S7-backed cache entry (CacheEntry)

## Usage

``` r
CacheEntry(family = character(0), meta = CacheMeta())
```

## Arguments

- family:

  (`character(1)`) Family name for this cache entry (safe identifier
  containing only letters, digits, and hyphens).

- meta:

  (`CacheMeta`) A `CacheMeta` object describing the cached files and
  origin for this family.

## Value

(`S7_object`) A validated S7 `CacheEntry` object.
