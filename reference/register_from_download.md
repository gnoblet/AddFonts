# Download necessary variants for a font, write a cache entry and register the font with `sysfonts`. Returns the prepared `files` list on success, or `NULL` if a regular font could not be obtained.

This function downloads fonts, creates a cache entry, and then calls
register_from_cache() to perform the actual registration with sysfonts.

## Usage

``` r
register_from_download(
  provider,
  name,
  font_id,
  family_name,
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin",
  cache_dir = NULL
)
```

## Arguments

- provider:

  (`FontProvider`) Provider object used for downloads.

- name:

  (`character(1)`) Font name at the provider.

- font_id:

  (`character(1)`) Filesystem-safe font id.

- family_name:

  (`character(1)`) Family name to register the font under.

- regular.wt:

  (`integer(1)`) Regular weight to fetch (default: 400)

- bold.wt:

  (`integer(1)`) Bold weight to fetch (default: 700)

- subset:

  (`character(1)`) Glyph subset to request (default: "latin")

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL)

## Value

(`list | NULL`) List of local file paths for variants, or `NULL` on
failure.
