# Base font provider class (FontProvider)

Abstract base class shared by all provider types. Do not construct this
directly. Use
[`FontProviderWeight()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderWeight.md)
or
[`FontProviderFile()`](http://guillaume-noblet.com/AddFonts/reference/FontProviderFile.md)
instead.

## Usage

``` r
FontProvider(
  source = character(0),
  aliases = list(),
  first_use_message = character(0),
  first_use_url = character(0)
)
```

## Arguments

- source:

  (`character(1)`) Provider id/name (e.g. `"bunny"`, `"bbb"`).

- aliases:

  (`list`) Optional list of alias strings to recognise the provider by
  (e.g. `list("fonts.bunny.net")`).

- first_use_message:

  (`character(1) | NULL`) Optional message displayed once per R session
  the first time this provider is used (e.g. a licensing notice). `NULL`
  means no message.

- first_use_url:

  (`character(1) | NULL`) Optional URL shown alongside
  `first_use_message`. `NULL` means no URL.

## Value

(`FontProvider`) S7 base class. Use a subclass constructor in practice.
