# File-based font provider (FontProviderFile)

Provider that downloads font files directly by filename from a base URL,
with no weight/style/subset parameterisation. Covers Git-hosted
collections like Bye Bye Binary where each variant has a fixed filename.

## Usage

``` r
FontProviderFile(
  source,
  base_url,
  file_ext = "ttf",
  aliases = list(),
  first_use_message = NULL,
  first_use_url = NULL
)
```

## Arguments

- source:

  (`character(1)`) Provider id/name (e.g. `"bbb"`).

- base_url:

  (`character(1)`) Glue-style URL template. Must contain `{family}` and
  `{filename}` placeholders (e.g.
  `"https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf"`).

- file_ext:

  (`character(1)`) Extension of the font files served by this provider
  (default: `"ttf"`). Must be `"ttf"` or `"otf"` (no conversion is
  performed).

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

(`FontProviderFile`) A validated S7 `FontProviderFile` object.
