# Clear Font Cache

Removes cached Bunny Fonts to free up space or force re-download.

## Usage

``` r
clear_font_cache_dir(confirm = TRUE)
```

## Arguments

- confirm:

  (`logical(1)`) Whether to ask for confirmation before deleting cached
  files (default: `TRUE`).

## Value

(`: logical(1)`) TRUE if cache was cleared successfully, FALSE
otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
# Clear cache with confirmation
clear_font_cache_dir()

# Clear cache without confirmation
clear_font_cache_dir(confirm = FALSE)
} # }
```
