#' Clear Font Cache
#'
#' Removes cached Bunny Fonts to free up space or force re-download.
#'
#' @typed confirm: logical(1)
#'   Whether to ask for confirmation before deleting cached files
#'   (default: `TRUE`).
#'
#' @typedreturn: logical(1)
#'   TRUE if cache was cleared successfully, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#' # Clear cache with confirmation
#' clear_font_cache_dir()
#'
#' # Clear cache without confirmation
#' clear_font_cache_dir(confirm = FALSE)
#' }
#'
#' @export
clear_font_cache_dir <- function(confirm = TRUE) {
  # Validate parameter
  if (!is.logical(confirm) || length(confirm) != 1 || is.na(confirm)) {
    cli::cli_abort(
      "{.arg confirm} must be a single logical value (TRUE or FALSE)."
    )
  }

  # Get cache directory
  cache_dir <- get_font_cache_dir()

  # If directory doesn't exist, nothing to clear
  if (!fs::dir_exists(cache_dir)) {
    cli::cli_alert_info("No font cache directory found.")
    return(TRUE)
  }

  # List all cached files
  cached_files <- fs::dir_ls(cache_dir, type = "file", glob = "*.woff2")

  if (length(cached_files) == 0) {
    cli::cli_alert_info("No cached fonts found in {.path {cache_dir}}")
    return(TRUE)
  }

  if (confirm && interactive()) {
    cli::cli_alert_info("Found {length(cached_files)} cached font file{?s}:")
    for (f in cached_files) {
      cli::cli_li("{.file {basename(f)}}")
    }

    # Ask for confirmation up to 3 times
    max_tries <- 3
    tries <- 0
    while (tries < max_tries) {
      response <- readline(prompt = "Delete these files? (y/N): ")
      resp_low <- tolower(trimws(response))

      if (resp_low %in% c("n", "no", "")) {
        cli::cli_alert_info("Cache clearing cancelled.")
        return(FALSE)
      } else if (resp_low %in% c("y", "yes")) {
        cli::cli_alert_info("Proceeding to delete cached files...")
        break
      } else {
        cli::cli_alert_warning("Invalid response (must be y/N).")
        tries <- tries + 1
        if (tries < max_tries) {
          cli::cli_alert_info(
            "Please try again (attempt {tries + 1} of {max_tries})."
          )
        }
      }
    }

    # If we get here and didn't break, user failed to give valid answer
    if (tries >= max_tries) {
      cli::cli_alert_danger(
        "Too many invalid attempts - cache clearing aborted."
      )
      return(FALSE)
    }
  }

  # Attempt to delete files
  success <- tryCatch(
    {
      fs::file_delete(cached_files)
      TRUE
    },
    error = function(e) {
      cli::cli_alert_warning(
        "Failed to delete some files: {conditionMessage(e)}"
      )
      FALSE
    }
  )

  if (success) {
    cli::cli_alert_success("Font cache cleared successfully.")
  }

  success
}
