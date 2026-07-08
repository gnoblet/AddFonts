# Get provider details from internal data

Load and return a FontProvider object for the specified provider. The
providers data is stored in the package's internal sysdata.rda.

## Usage

``` r
get_provider_details(provider)
```

## Arguments

- provider:

  (`character(1)`) Provider id/name (e.g. "bunny").

## Value

(`FontProvider`) A validated FontProvider object.
