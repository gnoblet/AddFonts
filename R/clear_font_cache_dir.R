#' Clear Font Cache
#'
#' Removes cached Bunny Fonts to free up space or force re-download.
#'
#' @param confirm Logical. Whether to ask for confirmation before deleting
#'   cached files. Default: TRUE.
#'
#' @return Logical. TRUE if cache was cleared successfully, FALSE otherwise.
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
  checkmate::assert_logical(confirm, len = 1, any.missing = FALSE)

  # Get cache directory
  cache_dir <- get_font_cache_dir()

  # If directory doesn't exist, nothing to clear
  if (!fs::dir_exists(cache_dir)) {
    message("No font cache directory found.")
    return(TRUE)
  }

  # List cached font files
  cached_files <- fs::dir_ls(
    cache_dir,
    glob = "*.woff2"
  )

  # If no cached files, nothing to clear
  if (length(cached_files) == 0) {
    message("No cached Bunny Fonts found.")
    return(TRUE)
  }

  # If confirm is TRUE, prompt user
  if (confirm) {
    # List files to be deleted
    message(sprintf("Found %d cached font file(s):", length(cached_files)))
    for (f in cached_files) {
      message("  - ", fs::path_file(f))
    }

    # Ask for confirmation up to 3 times
    max_tries <- 3
    tries <- 0
    while (tries < max_tries) {
      response <- readline(prompt = "Delete these files? (y/N): ")
      resp_low <- tolower(trimws(response))

      if (resp_low %in% c("n", "no", "")) {
        message("Cache clearing cancelled.")
        return(FALSE)
      } else if (resp_low %in% c("y", "yes")) {
        message("Proceeding to delete cached files...")
        break
      } else {
        message("Invalid response (must be y/N).")
        tries <- tries + 1
        if (tries < max_tries) {
          message(sprintf(
            "Please try again (attempt %d of %d).",
            tries + 1,
            max_tries
          ))
        }
      }
    }

    # If we get here and didn't break, user failed to give valid answer
    if (tries >= max_tries) {
      message("Too many invalid attempts - cache clearing aborted.")
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
      warning("Failed to delete some files: ", e$message)
      FALSE
    }
  )

  if (success) {
    message("Font cache cleared successfully.")
  }

  success
}
