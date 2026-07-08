# Construct a FontProvider subclass from a named list

Reads the `type` field (`"weight"` or `"file"`) and constructs the
appropriate subclass. Missing `type` defaults to `"weight"` for backward
compatibility with existing `providers.json` entries.

## Usage

``` r
as_FontProvider(x)

## S7 method for class <list>
as_FontProvider(x)
```

## Arguments

- x:

  (`list`) Named list (e.g. from JSON) with provider details.

## Value

(`FontProviderWeight | FontProviderFile`) The corresponding provider
object.
