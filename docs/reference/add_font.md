# Add a font to the local cache and register it for use

Ensure a font is available locally: try the cache first, otherwise
download/convert and register the font so it can be used by plotting
devices. Returns (invisibly) the list of local file paths.

## Usage

``` r
add_font(
  name,
  provider = "bunny",
  family = NULL,
  variants = NULL,
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin"
)
```

## Arguments

- name:

  (`character(1)`) Name of the font as known to the provider.

- provider:

  (`character(1) | FontProvider`) Provider id/name (default: `"bunny"`),
  or a `FontProvider` object constructed with
  [`FontProviderWeight()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderWeight.md)
  or
  [`FontProviderFile()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderFile.md)
  (bypasses the registry lookup).

- family:

  (`character | NULL`) Optional family name to register the font under
  (default: NULL).

- variants:

  (`list | NULL`) For file-based providers only. Named list mapping
  symbolic variant keys (`"regular"`, `"italic"`, `"bold"`,
  `"bolditalic"`) to filename stems served by the provider (without
  extension). Must include at least `"regular"`. Ignored for
  weight-based providers (default: NULL).

- regular.wt:

  (`numeric(1)`) For weight-based providers. Regular weight to request
  (default: 400).

- bold.wt:

  (`numeric(1)`) For weight-based providers. Bold weight to request
  (default: 700).

- subset:

  (`character(1)`) For weight-based providers. Glyph subset to request
  (default: "latin").

## Value

(`list`) Invisibly returns a list with paths for `regular`, `italic`,
`bold` and `bolditalic` variants, or throws an error on failure.

## Details

For weight-based providers (e.g. Bunny Fonts), supply
`regular.wt`,`bold.wt`, and `subset`. For file-based providers (e.g. Bye
Bye Binary), supply `variants` instead.
