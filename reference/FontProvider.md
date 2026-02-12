# Font provider specification (FontProvider)

Font provider specification (FontProvider)

## Usage

``` r
FontProvider(
  source = character(0),
  url_template = character(0),
  conversion = NULL,
  conversion_ext = NULL,
  aliases = list()
)
```

## Arguments

- source:

  (`character(1)`) Provider id/name (e.g. "bunny").

- url_template:

  (`character(1)`) URL template used to construct download URLs.

- conversion:

  (`character(1) | NULL`) Optional conversion function name (as string)
  or `NULL`.

- conversion_ext:

  (`character(1) | NULL`) Original extension handled by the provider
  (e.g. "woff2").

- aliases:

  (`list | NULL`) Optional list of alias names to match (e.g.
  "fonts.bunny.net").

## Value

(`FontProviders`) S7 class representing a font provider specification.
