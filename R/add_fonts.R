#' Add Fonts from Multiple Providers
#'
#' A general function to download and register fonts from various providers.
#' Currently supports Bunny Fonts, with more providers planned for the future.
#'
#' @param name Character. The font name as listed by the provider.
#' @param provider Character. Font provider to use. Currently supports:
#'   \itemize{
#'     \item \code{"bunny"}: Bunny Fonts (default) - privacy-focused Google Fonts alternative
#'   }
#' @param family Character. The family name to register in R. Defaults to `name`.
#' @param regular.wt Integer. The weight of the regular font variant (default: 400).
#' @param bold.wt Integer. The weight of the bold font variant (default: 700).
#' @param italic Logical. Whether to download italic variant (default: TRUE if available).
#' @param ... Additional provider-specific arguments.
#'
#' @return Invisibly returns a list of paths to the registered font files.
#' @export
#'
#' @examples
#' \dontrun{
#' # Add a font from Bunny Fonts (default provider)
#' add_font("roboto")
#'
#' # Explicitly specify provider
#' add_font("open-sans", provider = "bunny")
#'
#' # Customize font properties
#' add_font("inter", family = "Inter", regular.wt = 300, bold.wt = 600)
#'
#' # Enable showtext and use the font
#' showtext::showtext_auto()
#' plot(1:10, main = "Using fonts from multiple providers!")
#' }
add_font <- function(
  name,
  provider = "bunny",
  family = NULL,
  regular.wt = 400,
  bold.wt = 700,
  italic = TRUE,
  ...
) {
  # Validate and normalize provider
  provider <- tolower(provider)
  supported_providers <- c("bunny")

  if (!provider %in% supported_providers) {
    stop(sprintf(
      "Provider '%s' is not supported. Available providers: %s",
      provider,
      paste(supported_providers, collapse = ", ")
    ))
  }

  # Create an object with the provider class for S3 dispatch
  obj <- structure(
    list(
      name = name,
      family = family,
      regular.wt = regular.wt,
      bold.wt = bold.wt,
      italic = italic
    ),
    class = c(paste0("font_provider_", provider), "font_provider")
  )
  add_font_dispatch(obj, ...)
}

#' @keywords internal
add_font_dispatch <- function(obj, ...) {
  UseMethod("add_font_dispatch")
}

#' @keywords internal
#' @export
add_font_dispatch.font_provider_bunny <- function(obj, ...) {
  # Call the provider-specific implementation
  add_font_bunny(
    name = obj$name,
    family = obj$family,
    regular.wt = obj$regular.wt,
    bold.wt = obj$bold.wt,
    italic = obj$italic,
    ...
  )
}

#' @keywords internal
#' @export
add_font_dispatch.default <- function(obj, ...) {
  stop(sprintf("No add_font method for provider"))
}
