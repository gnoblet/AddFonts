# Download all variants of a file-based font and add to cache

Downloads each named variant from a `FontProviderFile` provider, creates
a
[`CacheEntry()`](http://guillaume-noblet.com/AddFonts/reference/CacheEntry.md)
with symbolic keys (`"regular"`, `"italic"`, `"bold"`, `"bolditalic"`),
writes the entry to the cache, and returns it.

## Usage

``` r
download_and_cache_file(
  provider,
  name,
  family_name,
  variants,
  cache_dir = NULL
)
```

## Arguments

- provider:

  (`FontProviderFile`) A file-based provider object.

- name:

  (`character(1)`) Font name as known to the provider (used in URL
  template as `{family}`).

- family_name:

  (`character(1)`) Family name under which to register the font.

- variants:

  (`list`) Named list mapping symbolic variant keys to filename stems.
  Names must be a subset of
  `c("regular", "italic", "bold", "bolditalic")`. At minimum,
  `"regular"` must be present. Values are filename stems without
  extension (e.g.
  `list(regular = "Alpaga-Regular", bold = "Alpaga-Bold")`).

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL).

## Value

(`CacheEntry | NULL`) Cache entry with downloaded variants, or `NULL` if
the regular variant could not be downloaded.
