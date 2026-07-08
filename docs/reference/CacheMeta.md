# S7-backed cache metadata (CacheMeta)

S7-backed cache metadata (CacheMeta)

## Usage

``` r
CacheMeta(source, files, key_scheme = NULL, failed_keys = character(0))
```

## Arguments

- source:

  (`character(1)`) Name of the provider or source that produced the
  cached font files.

- files:

  (`list(1+)`) A non-empty named list of file paths. Names must follow
  the scheme declared by `key_scheme`. (default: NULL)

- key_scheme:

  (`character(1)`) Key scheme used in `files`: `"weight"` for numeric
  weight keys (e.g. `"400"`, `"700italic"`) or `"symbolic"` for variant
  keys (`"regular"`, `"bold"`, etc.).

- failed_keys:

  (`character(0+)`) A character vector of keys that were requested but
  failed to download. Empty if all requested keys were successfully
  downloaded. (default: character(0))

## Value

(`S7_object`) A validated S7 `CacheMeta` object.
