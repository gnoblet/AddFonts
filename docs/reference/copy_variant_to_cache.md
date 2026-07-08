# Copy one local font file into the cache

Copies a local font file into the AddFonts cache directory, naming it
according to the standard `"file-{family}-{variant}.{ext}"` convention.

## Usage

``` r
copy_variant_to_cache(
  src_path,
  family,
  variant,
  cache_dir = NULL,
  quiet = FALSE
)
```

## Arguments

- src_path:

  (`character(1)`) Absolute path to the source font file.

- family:

  (`character(1)`) Family identifier used in the cache filename.

- variant:

  (`character(1)`) Symbolic variant key: one of `"regular"`, `"italic"`,
  `"bold"`, `"bolditalic"`.

- cache_dir:

  (`character | NULL`) Cache directory. Defaults to
  [`get_cache_dir()`](http://guillaume-noblet.com/AddFonts/reference/get_cache_dir.md)
  when `NULL`.

- quiet:

  (`logical(1)`) Suppress warnings/messages (default: FALSE).

## Value

(`character | NULL`) Path to the cached file on success, or `NULL` on
failure.
