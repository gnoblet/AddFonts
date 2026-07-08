# Validate a variants list

Checks that `variants` is a non-`NULL` named list whose names are a
subset of the recognised symbolic keys and contains at least
`"regular"`. Aborts with an informative error on the first violation
found.

## Usage

``` r
.validate_variants(variants)
```

## Arguments

- variants:

  (`list`) Named list of symbolic variant keys to font-specific values
  (filename stems, absolute paths, or URLs depending on the caller).

## Value

(`NULL`) Returns `invisible(NULL)` on success; called for its
side-effect.
