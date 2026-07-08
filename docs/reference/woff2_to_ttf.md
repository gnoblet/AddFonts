# Convert a .woff2 font to .ttf using the system 'woff2_decompress' tool

Internal helper. Uses the system `woff2_decompress` tool to convert a
`.woff2` file into a `.ttf` file.

## Usage

``` r
woff2_to_ttf(font_file, overwrite = FALSE, remove_old = TRUE, quiet = FALSE)
```

## Arguments

- font_file:

  (`character(1)`) Path to the `.woff2` file to convert.

- overwrite:

  (`logical(1)`) If `TRUE`, overwrite an existing `.ttf` conversion.

- remove_old:

  (`logical(1)`) If `TRUE`, remove the original `.woff2` file after
  conversion try.

- quiet:

  (`logical(1)`) If `TRUE`, suppress the success message. Errors always
  abort regardless of this setting (default: `FALSE`).

## Value

(`character(1)`) Invisibly returns the path to the `.ttf` file on
success.
