# Download a URL to a local file via httr2

Issues an HTTP GET for `url`, writing the response body to `local_path`.
On failure (httr2 error or missing output file) warns (unless `quiet`)
and returns `NULL`.

## Usage

``` r
.fetch_url_to_cache(url, local_path, family, variant, quiet)
```

## Arguments

- url:

  (`character(1)`) Full URL to fetch.

- local_path:

  (`character(1)`) Destination path for the downloaded file.

- family:

  (`character(1)`) Font family name — used in warning messages only.

- variant:

  (`character(1)`) Variant key — used in warning messages only.

- quiet:

  (`logical(1)`) Suppress warnings and messages.

## Value

(`character | NULL`) `local_path` on success, or `NULL` on failure.
