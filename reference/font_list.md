# List Fonts from Multiple Providers

A general function to list available fonts from various providers.
Currently supports Bunny Fonts, with more providers planned for the
future.

## Usage

``` r
font_list(provider = "bunny", ...)
```

## Arguments

- provider:

  (`character(1)`) Font provider to query. Currently supports "bunny"
  for Bunny Fonts (default: `"bunny"`).

- ...:

  Additional provider-specific arguments (currently unused).

## Value

(`: data.frame`) A data.frame with font metadata from the specified
provider.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all fonts from default provider (Bunny)
fonts <- font_list()
head(fonts)

# Explicitly specify provider
bunny_fonts <- font_list(provider = "bunny")

# Count fonts by category
table(fonts$category)
} # }
```
