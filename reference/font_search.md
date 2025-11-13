# Search Fonts from Multiple Providers

A general function to search for available fonts from various providers.
Currently supports Bunny Fonts, with more providers planned for the
future.

## Usage

``` r
font_search(query = NULL, provider = "bunny", category = NULL, ...)
```

## Arguments

- query:

  (`character(1) or NULL`) String to search for in font names or
  categories (default: `NULL`, returns all fonts, optionally filtered by
  category).

- provider:

  (`character(1)`) Font provider to search. Currently supports "bunny"
  for Bunny Fonts (default: `"bunny"`).

- category:

  (`character(1) or NULL`) Filter by category (provider-specific). For
  Bunny Fonts: "sans-serif", "serif", "display", "handwriting",
  "monospace" (default: `NULL`, all categories).

- ...:

  Additional provider-specific arguments (currently unused).

## Value

(`: data.frame`) A data.frame with matching font metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# Search all providers (currently just Bunny)
font_search("roboto")

# Search within a specific category
font_search("sans", category = "sans-serif")

# List all monospace fonts
font_search(category = "monospace")

# Explicitly specify provider
font_search("inter", provider = "bunny")
} # }
```
