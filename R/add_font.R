#' Add Fonts from Multiple Providers
#'
#' A general function to download and register fonts from various providers.
#' Currently supports Bunny Fonts, with more providers planned for the future.
#'
#' @typed name: character(1)
#'   The font name as listed by the provider.
#' @typed provider: character(1)
#'   Font provider to use. Currently supports "bunny" for Bunny Fonts,
#'   a privacy-focused Google Fonts alternative (default: `"bunny"`).
#' @typed family: character(1) or NULL
#'   The family name to register in R (default: `NULL`, uses `name`).
#' @typed wt: numeric or NULL
#'   Font weights to download (e.g., c(400, 700)).
#'   Use a vector to specify only certain weights (e.g., c(300, 500, 700))
#'   (default: `NULL`, downloads all available weights).
#' @typed styles: character(1)
#'   Which styles to download: "normal", "italic", or "both".
#'   Set to "normal" for regular styles only, "italic" for italic only,
#'   or "both" for all available styles (default: `"both"`).
#' @param ... Additional provider-specific arguments.
#'
#' @typedreturn: list
#'   Invisibly returns a list of paths to the registered font files.
#' @export
#'
#' @examples
#' \dontrun{
#' # Add a font from Bunny Fonts (default provider) with all weights/styles
#' add_font("roboto")
#'
#' # Add only specific weights
#' add_font("open-sans", wt = c(400, 700))
#'
#' # Add only normal (non-italic) styles
#' add_font("inter", wt = c(300, 400, 700), styles = "normal")
#'
#' # Add italic styles only with custom family name
#' add_font("merriweather", family = "Merri", wt = c(400, 700), styles = "italic")
#'
#' # Explicitly specify provider
#' add_font("source-code-pro", provider = "bunny", wt = 400)
#'
#' # Enable showtext and use the font
#' showtext::showtext_auto()
#' plot(1:10, main = "Using fonts from multiple providers!")
#' }
add_font <- function(
  name,
  provider = "bunny",
  family = NULL,
  wt = NULL,
  styles = "both",
  ...
) {
  # Validate and normalize provider
  provider <- tolower(provider)

  # Dispatch to provider-specific function
  switch(
    provider,
    bunny = add_font_bunny(
      name = name,
      family = family,
      wt = wt,
      styles = styles,
      ...
    ),
    # When adding more providers, add them here:
    # google = add_font_google(...),
    # Add default case for unsupported providers
    cli::cli_abort(c(
      "Provider {.val {provider}} is not supported.",
      "i" = "Currently supported: {.val bunny}"
    ))
  )
}
