# Weight-based font provider (FontProviderWeight)

Provider that resolves font variants by numeric weight and style via a
glue-style URL template. This covers APIs like Bunny Fonts.

## Usage

``` r
FontProviderWeight(
  source,
  url_template,
  conversion = NULL,
  conversion_ext = NULL,
  aliases = list(),
  first_use_message = NULL,
  first_use_url = NULL
)
```

## Arguments

- source:

  (`character(1)`) Provider id/name (e.g. `"bunny"`).

- url_template:

  (`character(1)`) Glue-style URL template. Must contain `{family}`.
  Typically also uses `{subset}`, `{weight}` (integer), and `{style}`.

- conversion:

  (`character(1) | NULL`) Name of a conversion function to apply after
  download (e.g. `"woff2_to_ttf"`), or `NULL` if the provider serves TTF
  directly.

- conversion_ext:

  (`character(1) | NULL`) File extension of the downloaded artifact
  before conversion (e.g. `"woff2"`), or `NULL`.

- aliases:

  (`list`) Optional alias strings (inherited from
  [`FontProvider()`](http://guillaume-noblet.com/AddFonts/reference/FontProvider.md)).

- first_use_message:

  (`character(1) | NULL`) Inherited from
  [`FontProvider()`](http://guillaume-noblet.com/AddFonts/reference/FontProvider.md).

- first_use_url:

  (`character(1) | NULL`) Inherited from
  [`FontProvider()`](http://guillaume-noblet.com/AddFonts/reference/FontProvider.md).

## Value

(`FontProviderWeight`) A validated S7 `FontProviderWeight` object.
