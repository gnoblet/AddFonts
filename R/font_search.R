#' Search Fonts from Multiple Providers
#'
#' A general function to search for available fonts from various providers.
#' Currently supports Bunny Fonts, with more providers planned for the future.
#'
#' @param query Character string to search for in font names or categories.
#'   If NULL or empty, returns all fonts (optionally filtered by category).
#' @param provider Character. Font provider to search. Currently supports:
#'   \itemize{
#'     \item \code{"bunny"}: Bunny Fonts (default)
#'   }
#' @param category Character. Filter by category (provider-specific).
#'   For Bunny Fonts: "sans-serif", "serif", "display", "handwriting", "monospace".
#'   Default: NULL (all categories).
#' @param ... Additional provider-specific arguments.
#'
#' @return A data.frame with matching font metadata.
#' @export
#'
#' @examples
#' \dontrun{
#' # Search all providers (currently just Bunny)
#' font_search("roboto")
#'
#' # Search within a specific category
#' font_search("sans", category = "sans-serif")
#'
#' # List all monospace fonts
#' font_search(category = "monospace")
#'
#' # Explicitly specify provider
#' font_search("inter", provider = "bunny")
#' }
font_search <- function(
  query = NULL,
  provider = "bunny",
  category = NULL,
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
    list(query = query, category = category),
    class = c(paste0("font_provider_", provider), "font_provider")
  )
  font_search_dispatch(obj, ...)
}

#' @keywords internal
font_search_dispatch <- function(obj, ...) {
  UseMethod("font_search_dispatch")
}

#' @keywords internal
#' @export
font_search_dispatch.font_provider_bunny <- function(obj, ...) {
  fonts <- font_list_bunny()

  query <- obj$query
  category <- obj$category

  # Filter by category if specified
  if (!is.null(category) && nzchar(category)) {
    fonts <- fonts[tolower(fonts$category) == tolower(category), , drop = FALSE]
  }

  # Search by query if specified
  if (!is.null(query) && nzchar(query)) {
    matches <- grepl(query, fonts$family, ignore.case = TRUE) |
      grepl(query, fonts$familyName, ignore.case = TRUE) |
      grepl(query, fonts$category, ignore.case = TRUE)
    fonts <- fonts[matches, , drop = FALSE]
  }

  if (nrow(fonts) == 0) {
    message("No fonts found matching the search criteria.")
  }

  # Return a nice output with familyName and a nice table with font weights and categories
  output <- fonts[, c("familyName", "category", "weights")]
  output$weights <- sapply(output$weights, function(x) {
    paste(x, collapse = ", ")
  })
  output
}

#' @keywords internal
#' @export
font_search_dispatch.default <- function(obj, ...) {
  stop(sprintf("No font_search method for provider"))
}

#' Search Bunny Fonts by Name or Category (Direct Function)
#'
#' Search for fonts available on Bunny Fonts by name, category, or other attributes.
#' This is a convenience function that directly searches Bunny Fonts without going
#' through the generic interface.
#'
#' @param query Character string to search for in font names or categories.
#'   If NULL or empty, returns all fonts (optionally filtered by category).
#' @param category Character. Filter by category (e.g., "sans-serif", "serif",
#'   "display", "handwriting", "monospace"). Default: NULL (all categories).
#' @return A data.frame with matching font metadata, or an empty data.frame if no matches.
#' @examples
#' \dontrun{
#' # Search for fonts with "sans" in the name
#' font_search_bunny("sans")
#'
#' # Search within a specific category
#' font_search_bunny("roboto", category = "sans-serif")
#'
#' # List all monospace fonts
#' font_search_bunny(category = "monospace")
#'
#' # List all available fonts
#' font_search_bunny()
#' }
#' @export
font_search_bunny <- function(query = NULL, category = NULL) {
  font_search(query = query, provider = "bunny", category = category)
}
