# S7-backed cache metadata (CacheMeta)

S7-backed cache metadata (CacheMeta)

## Usage

``` r
CacheMeta(family_id = character(0), source = character(0), files = list())
```

## Arguments

- family_id:

  (`character(1)`) A non-empty safe identifier for the font family.
  Allowed characters: letters, digits and hyphen (no spaces, slashes,
  dots, colons, tildes, etc.).

- source:

  (`character(1)`) Name of the provider or source that produced the
  cached font files.

- files:

  (`list(1+)`) A non-empty named list of file paths. Names are weight
  identifiers (e.g., "400" for normal weight 400, "400italic" for italic
  weight 400). Each element is a character(1) path to the local font
  files.

## Value

(`S7_object`) A validated S7 `CacheMeta` object.

## Details

The `added` property is a getter-only field that returns the current
timestamp as a character string when accessed. It cannot be set during
construction.

Weights are not explicitly stored - they are derived from the names of
the files list. Registration functions are responsible for selecting
appropriate weights for regular/bold variants.
