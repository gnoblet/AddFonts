# Download one font file from a file-based provider

Downloads a single font variant directly from a `FontProviderFile` using
its `base_url` template. No conversion is performed — the file is stored
as received.

## Usage

``` r
download_variant_file(
  provider,
  family,
  filename,
  variant,
  cache_dir = NULL,
  quiet = FALSE
)
```

## Arguments

- provider:

  (`FontProviderFile`) A file-based provider object.

- family:

  (`character(1)`) Family identifier used in the URL template and cache
  filename.

- filename:

  (`character(1)`) Filename stem (without extension) for the specific
  variant (e.g. `"Alpaga-Regular"`). Substituted into the `{filename}`
  placeholder of `provider@base_url`.

- variant:

  (`character(1)`) Symbolic key for this variant: one of `"regular"`,
  `"italic"`, `"bold"`, `"bolditalic"`.

- cache_dir:

  (`character | NULL`) Cache directory to use (default: NULL).

- quiet:

  (`logical(1)`) Suppress warnings/messages (default: FALSE).

## Value

(`character | NULL`) Path to the locally cached font file on success, or
`NULL` on failure.
