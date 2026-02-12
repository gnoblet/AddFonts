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
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin"
)
```

## Arguments

- name:

  (`character(1)`) Name of the font as known to the provider.

- provider:

  (`character(1)`) Provider id/name (default: "bunny").

- family:

  (`character | NULL`) Optional family name to register the font under
  (default: NULL).

- regular.wt:

  (`numeric(1)`) Regular weight to request (default: 400).

- bold.wt:

  (`numeric(1)`) Bold weight to request (default: 700).

- subset:

  (`character(1)`) Glyph subset to request (default: "latin").

## Value

(`list`) Invisibly returns a list with paths for `regular`, `italic`,
`bold` and `bolditalic` variants, or throws an error on failure.
