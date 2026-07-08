# Compute canonical cache path for a file-based (symbolic-variant) font file

Used by file-based providers (e.g. Bye Bye Binary) where each variant is
identified by a symbolic key (`"regular"`, `"italic"`, `"bold"`,
`"bolditalic"`) rather than a numeric weight.

## Usage

``` r
cache_file_path(source, family, variant, file_ext, cache_dir = NULL)
```

## Arguments

- source:

  (`character(1)`) Provider source identifier.

- family:

  (`character(1)`) Family name (will be made filesystem-safe via
  [`safe_id()`](http://guillaume-noblet.com/AddFonts/reference/safe_id.md)).

- variant:

  (`character(1)`) Symbolic variant key: one of `"regular"`, `"italic"`,
  `"bold"`, `"bolditalic"`.

- file_ext:

  (`character(1)`) File extension of the cached font (e.g. `"ttf"`,
  `"otf"`).

- cache_dir:

  (`character | NULL`) Cache directory. Defaults to
  [`get_cache_dir()`](http://guillaume-noblet.com/AddFonts/reference/get_cache_dir.md)
  when `NULL`.

## Value

(`character(1)`) Full path to the locally cached font file.
