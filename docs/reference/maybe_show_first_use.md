# Show a provider's first-use message, at most once per session

If `provider@first_use_message` is non-NULL and no message has been
shown for this provider's source in the current R session, emits the
message via
[`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html)
and records that it has been shown. Subsequent calls for the same
provider are silently ignored.

## Usage

``` r
maybe_show_first_use(provider)
```

## Arguments

- provider:

  (`FontProvider`) The provider object whose message should (possibly)
  be displayed.

## Value

(`invisible(NULL)`) Called for its side-effect only.
