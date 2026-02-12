# Resolve a conversion name to the converter function used by the package (currently only `woff2_to_ttf`).

Resolve a conversion name to the converter function used by the package
(currently only `woff2_to_ttf`).

## Usage

``` r
conv_fun(conversion)
```

## Arguments

- conversion:

  (`character(1)`) Name of the conversion to resolve.

## Value

(`function`) The conversion function if known; otherwise the helper
aborts.
