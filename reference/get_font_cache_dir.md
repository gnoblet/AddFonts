# Get Font Cache Directory

Returns the directory where fonts are/should be cached. Uses
platform-appropriate cache locations via the rappdirs package.

## Usage

``` r
get_font_cache_dir()
```

## Value

(`: character(1)`) Absolute path to the fonts cache directory.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get font cache directory
cache_dir <- get_font_cache_dir()
print(cache_dir)
} # }
```
