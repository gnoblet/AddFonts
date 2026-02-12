# Preview a font by ensuring it's installed and drawing a sample string

Ensure the requested font is installed via
[`add_font()`](http://guillaume-noblet.com/AddFonts/reference/add_font.md)
and draw a brief sample using `showtext` for proper font rendering.

## Usage

``` r
preview_font(
  name,
  provider = "bunny",
  family = NULL,
  sample = "The quick brown fox jumps over the lazy dog",
  size = 28,
  subset = "latin",
  regular.wt = 400,
  bold.wt = 700
)
```

## Arguments

- name:

  (`character(1)`) Font name as used by the provider (e.g. "oswald").

- provider:

  (`character(1)`) Provider name to use (default: "bunny")

- family:

  (`character | NULL`) Optional family name to register the font under
  (default: NULL)

- sample:

  (`character(1)`) Sample text to display (default: "The quick brown fox
  jumps over the lazy dog")

- size:

  (`numeric(1)`) Font size in points for the preview (default: 28)

- subset:

  (`character(1)`) Glyph subset to request (default: "latin")

- regular.wt:

  (`integer(1)`) Regular weight to display (default: 400)

- bold.wt:

  (`integer(1)`) Bold weight to display (default: 700)

## Value

(`list`) Invisibly returns the list of paths produced by
[`add_font()`](http://guillaume-noblet.com/AddFonts/reference/add_font.md).
