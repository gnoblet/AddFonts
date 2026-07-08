# List all available font providers

Returns a named list of all `FontProvider` objects: built-in providers
first, then any providers registered in the current session. Session
providers with the same source name as a built-in take precedence.

## Usage

``` r
list_providers()
```

## Value

(`list`) Named list of `FontProvider` objects keyed by their source
name.
