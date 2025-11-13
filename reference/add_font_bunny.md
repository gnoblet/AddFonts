# Download and Register a Font from Bunny Fonts

Downloads a font from [fonts.bunny.net](https://fonts.bunny.net/),
caches it locally, and registers it for use in R graphics devices via
`sysfonts` and `showtext`. This provides a privacy-focused alternative
to Google Fonts.

## Usage

``` r
add_font_bunny(
  name,
  family = NULL,
  wt = NULL,
  styles = "both",
  regular.wt = NULL,
  bold.wt = NULL,
  subset = NULL,
  cache_dir = NULL,
  ...
)
```

## Arguments

- name:

  (`character(1)`) The font name as listed on Bunny Fonts (e.g.,
  "open-sans"). Can be the family ID (lowercase with hyphens) or display
  name (case-insensitive).

- family:

  (`character(1) or NULL`) The family name to register in R (default:
  `NULL`, uses `name`).

- wt:

  (`numeric or NULL`) Font weights to download (e.g., c(400, 700)). Use
  a vector to specify only certain weights (e.g., c(300, 500, 700))
  (default: `NULL`, downloads all available weights).

- styles:

  (`character(1)`) Which styles to download: "normal", "italic", or
  "both". Set to "normal" for regular styles only, "italic" for italic
  only, or "both" for all available styles (default: `"both"`).

- regular.wt:

  (`numeric(1) or NULL`) Which weight to use as the regular font face
  for
  [`sysfonts::font_add()`](https://rdrr.io/pkg/sysfonts/man/font_add.html)
  (default: `NULL`, uses the first weight in `wt`).

- bold.wt:

  (`numeric(1) or NULL`) Which weight to use as the bold font face for
  [`sysfonts::font_add()`](https://rdrr.io/pkg/sysfonts/man/font_add.html)
  (default: `NULL`, uses the last weight in `wt`).

- subset:

  (`character(1) or NULL`) Font subset to use (e.g., "latin",
  "latin-ext") (default: `NULL`, uses the font's default subset).

- cache_dir:

  (`character(1) or NULL`) Directory to cache downloaded fonts (default:
  `NULL`, uses platform-appropriate cache directory via
  [`get_font_cache_dir()`](http://guillaume-noblet.com/AddFonts/reference/get_font_cache_dir.md)).

- ...:

  Additional arguments passed to
  [`sysfonts::font_add()`](https://rdrr.io/pkg/sysfonts/man/font_add.html).

## Value

(`: list`) Invisibly returns a list of paths to the registered font
files.

## Details

Font files are downloaded as WOFF2 and automatically converted to TTF
format for compatibility with `sysfonts`. This requires the
`woff2_decompress` command-line tool to be installed on your system.

## System Requirements

This function requires the `woff2_decompress` command-line tool to
convert downloaded WOFF2 files to TTF format. Install it using:

- **macOS:** `brew install woff2`

- **Debian/Ubuntu:** `sudo apt install woff2`

- **Fedora/RHEL:** `sudo dnf install woff2-tools`

- **Arch Linux:** `sudo pacman -S woff2`

- **Windows:** Build from <https://github.com/google/woff2>

## Examples

``` r
if (FALSE) { # \dontrun{
# Add a font with all weights and styles (default)
add_font_bunny("open-sans")

# Add only specific weights
add_font_bunny("roboto", wt = c(300, 400, 700))

# Add only normal (non-italic) styles
add_font_bunny("roboto", styles = "normal")

# Add specific weights in italic only
add_font_bunny("merriweather", wt = c(400, 700), styles = "italic")

# Specify which weights to use for regular and bold
add_font_bunny("roboto", wt = c(300, 400, 700), regular.wt = 400, bold.wt = 700)

# Specify custom family name
add_font_bunny("source-code-pro", family = "SourceCode", wt = 400)

# Enable showtext and use the font
showtext::showtext_auto()
plot(1:10, main = "This uses fonts from Bunny Fonts!")
} # }
```
