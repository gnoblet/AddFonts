# Download and (if needed) convert a provider artifact to a local TTF file for a given family/weight/style and return the local path.

Download and (if needed) convert a provider artifact to a local TTF file
for a given family/weight/style and return the local path.

## Usage

``` r
download_variant_generic(
  provider,
  family,
  weight,
  style,
  subset = "latin",
  cache_dir = NULL,
  quiet = FALSE
)
```

## Arguments

- provider:

  (`FontProvider`) Provider object with url_template and source.

- family:

  (`character(1)`) Family identifier.

- weight:

  (`integer(1)`) Font weight to fetch (100-900).

- style:

  (`character(1)`) Style (e.g. "normal", "italic").

- subset:

  (`character(1)`) Glyph subset to request (default: "latin")

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL)

- quiet:

  (`logical(1)`) Suppress warnings/messages (default: FALSE)

## Value

(`character | NULL`) Path to the local `.ttf` file on success, or `NULL`
on failure.
