#' Get Font Cache Directory
#'
#' Returns the directory where fonts are/should be cached.
#' Uses platform-appropriate cache locations via the rappdirs package.
#'
#' @typedreturn: character(1)
#'   Absolute path to the fonts cache directory.
#'
#' @examples
#' \dontrun{
#' # Get font cache directory
#' cache_dir <- get_font_cache_dir()
#' print(cache_dir)
#' }
#'
#' @export
get_font_cache_dir <- function() {
  # Use rappdirs to get user-specific cache directory for AddFonts
  cache_dir <- rappdirs::user_cache_dir("AddFonts")

  # Create directory if it doesn't exist
  if (!fs::dir_exists(cache_dir)) {
    fs::dir_create(cache_dir, recurse = TRUE)
    message("Created font cache directory at: ", cache_dir)
  }

  cache_dir
}
