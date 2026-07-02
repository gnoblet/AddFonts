#' Download font variants and add to cache
#'
#' Downloads font files for requested weights, creates a cache entry, and writes to cache. Does NOT register the font - caller should use register_from_cache() for that.
#'
#' @typed provider: FontProvider
#'   Provider object used for downloads.
#' @typed name: character(1)
#'   Font name at the provider.
#' @typed family_name: character(1)
#'   Family name for the font.
#' @typed regular.wt: integer(1)
#'   Regular weight to fetch (default: 400)
#' @typed bold.wt: integer(1)
#'   Bold weight to fetch (default: 700)
#' @typed subset: character(1)
#'   Glyph subset to request (default: "latin")
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL)
#'
#' @typedreturn CacheEntry | NULL
#'   Cache entry with downloaded fonts, or `NULL` on failure.
#'
download_and_cache <- function(
  provider,
  name,
  family_name,
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin",
  cache_dir = NULL
) {
  #------ Arg check
  if (!S7::S7_inherits(provider, FontProvider)) {
    cli::cli_abort("{.arg provider} must be a <FontProvider> object.")
  }

  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  #------ Download variants using helper
  files_entry <- download_weights(
    provider,
    name,
    c(regular.wt, bold.wt),
    subset,
    cache_dir,
    quiet = FALSE
  )

  # If regular font not available, cannot proceed
  if (!as.character(regular.wt) %in% names(files_entry)) {
    return(NULL)
  }

  # Record which requested normal-weight keys were not downloaded
  requested_keys <- as.character(c(regular.wt, bold.wt))
  failed_keys <- requested_keys[!requested_keys %in% names(files_entry)]

  .persist_cache_entry(provider@source, family_name, files_entry, cache_dir,
                       failed_keys = failed_keys)
}
