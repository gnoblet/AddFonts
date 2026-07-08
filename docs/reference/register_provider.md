# Register a font provider for the current session

Adds a `FontProvider` object to the session-level registry so it can be
referenced by name in
[`add_font()`](http://guillaume-noblet.com/AddFonts/reference/add_font.md).
The registry is cleared when the R session ends.

## Usage

``` r
register_provider(provider, overwrite = FALSE)
```

## Arguments

- provider:

  (`FontProvider`) A validated `FontProvider` object to register.

- overwrite:

  (`logical(1)`) If `TRUE`, silently overwrite an existing provider with
  the same source name. If `FALSE` (default), error instead.

## Value

(`NULL`) Called for its side-effect; returns `NULL` invisibly.
