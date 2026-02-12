# Create a filesystem-safe id from a name

Replace disallowed characters with `-` and convert to lower-case so the
resulting id is safe to use in filenames.

## Usage

``` r
safe_id(name)
```

## Arguments

- name:

  (`character(1)`) Input name to sanitise.

## Value

(`character(1)`) Sanitised identifier.
