#' List Fonts from Multiple Providers
#'
#' A general function to list available fonts from various providers.
#' Currently supports Bunny Fonts, with more providers planned for the future.
#'
#' @param provider Character. Font provider to query. Currently supports:
#'   \itemize{
#'     \item \code{"bunny"}: Bunny Fonts (default)
#'   }
#' @param ... Additional provider-specific arguments.
#'
#' @return A data.frame with font metadata from the specified provider.
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
    stop(sprintf(
      "Provider '%s' is not supported. Available providers: %s",
      provider,
      paste(supported_providers, collapse = ", ")
    ))
  }

  # Create an object with the provider class for S3 dispatch
  obj <- structure(
    provider,
    class = c(paste0("font_provider_", provider), "font_provider")
  )
  font_list_dispatch(obj, ...)
}

#' @keywords internal
font_list_dispatch <- function(obj, ...) {
  UseMethod("font_list_dispatch")
}

#' @keywords internal
#' @export
font_list_dispatch.font_provider_bunny <- function(obj, ...) {
  # Return the bundled data object
  fonts_bunny
}

#' @keywords internal
#' @export
font_list_dispatch.default <- function(obj, ...) {
  stop(sprintf(
    "No font_list method for provider: %s",
    gsub("font_provider_", "", class(obj)[1])
  ))
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
  fonts_bunny
}

#' Null coalescing operator
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
