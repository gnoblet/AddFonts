# Add Fonts from Multiple Providers

A general function to download and register fonts from various
providers. Currently supports Bunny Fonts, with more providers planned
for the future.

## Usage

``` r
add_font(
  name,
  provider = "bunny",
  family = NULL,
  wt = NULL,
  styles = "both",
  ...
)
```

## Arguments

- name:

  (`character(1)`) The font name as listed by the provider.

- provider:

  (`character(1)`) Font provider to use. Currently supports "bunny" for
  Bunny Fonts, a privacy-focused Google Fonts alternative (default:
  `"bunny"`).

- family:

  (`character(1) or NULL`) The family name to register in R (default:
  `NULL`, uses `name`).

- wt:

  (`numeric or NULL`) Font weights to download (e.g., c(400, 700)). Use
  a vector to specify only certain weights (e.g., c(300, 500, 700))
  (default: `NULL`, downloads all available weights).

- styles:

  (`character(1)`) Which styles to download: "normal", "italic", or
  "both". Set to "normal" for regular styles only, "italic" for italic
  only, or "both" for all available styles (default: `"both"`).

- ...:

  Additional provider-specific arguments.

## Value

(`: list`) Invisibly returns a list of paths to the registered font
files.

## Examples

``` r
if (FALSE) { # \dontrun{
# Add a font from Bunny Fonts (default provider) with all weights/styles
add_font("roboto")

# Add only specific weights
add_font("open-sans", wt = c(400, 700))

# Add only normal (non-italic) styles
add_font("inter", wt = c(300, 400, 700), styles = "normal")

# Add italic styles only with custom family name
add_font("merriweather", family = "Merri", wt = c(400, 700), styles = "italic")

# Explicitly specify provider
add_font("source-code-pro", provider = "bunny", wt = 400)

# Enable showtext and use the font
showtext::showtext_auto()
plot(1:10, main = "Using fonts from multiple providers!")
} # }
```
