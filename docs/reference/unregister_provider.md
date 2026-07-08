# Remove a font provider from the session registry

Dispatches on a source name (`character`) or a `FontProvider` object.

## Usage

``` r
unregister_provider(x)
```

## Arguments

- x:

  (`character(1) | FontProvider`) Source name of the provider to remove,
  or the `FontProvider` object itself.

## Value

(`NULL`) Called for its side-effect; returns `NULL` invisibly.
