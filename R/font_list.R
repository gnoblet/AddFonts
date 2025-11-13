#' List Fonts from Multiple Providers
#'
#' A general function to list available fonts from various providers.
#' Currently supports Bunny Fonts, with more providers planned for the future.
#'
#' @typed provider: character(1)
#'   Font provider to query. Currently supports "bunny" for Bunny Fonts
#'   (default: `"bunny"`).
#' @param ... Additional provider-specific arguments (currently unused).
#'
#' @typedreturn: data.frame
#'   A data.frame with font metadata from the specified provider.
#' @export
#'
#' @examples
#' \dontrun{
#' # List all fonts from default provider (Bunny)
#' fonts <- font_list()
#' head(fonts)
#'
#' # Explicitly specify provider
#' bunny_fonts <- font_list(provider = "bunny")
#'
#' # Count fonts by category
#' table(fonts$category)
#' }
font_list <- function(provider = "bunny", ...) {
  # Validate and normalize provider
  provider <- tolower(provider)
  supported_providers <- c("bunny")

  if (!provider %in% supported_providers) {
    cli::cli_abort(c(
      "Provider {.val {provider}} is not supported.",
      "i" = "Available providers: {.val {supported_providers}}"
    ))
  }

  # Currently only supports Bunny Fonts
  if (provider == "bunny") {
    fb <- fonts_bunny
    return(fb)
  }
}

#' List Available Fonts from Bunny.net (Direct Function)
#'
#' Retrieve the list of fonts available from fonts.bunny.net using the
#' package's bundled database. This is a convenience function that directly
#' returns Bunny Fonts without going through the generic interface.
#'
#' @return A data.frame with columns: family, familyName, category, weights,
#'   styles, defSubset, isVariable, and url representing the fonts metadata
#'   from Bunny Fonts.
#' @export
#'
#' @examples
#' # List all available fonts
#' fonts <- font_list_bunny()
#' head(fonts)
#'
#' # See how many fonts are in each category
#' table(fonts$category)
font_list_bunny <- function() {
  fb <- fonts_bunny
  return(fb)
}

#' Null coalescing operator
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
