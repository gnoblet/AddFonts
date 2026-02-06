#' Add a font to the local cache and register it for use
#'
#' Ensure a font is available locally: try the cache first, otherwise
#' download/convert and register the font so it can be used by plotting
#' devices. Returns (invisibly) the list of local file paths.
#'
#' @typed name: character(1)
#'   Name of the font as known to the provider.
#' @typed provider: character(1)
#'   Provider id/name (default: "bunny").
#' @typed family: character | NULL
#'   Optional family name to register the font under (default: NULL).
#' @typed regular.wt: numeric(1)
#'   Regular weight to request (default: 400).
#' @typed bold.wt: numeric(1)
#'   Bold weight to request (default: 700).
#' @typed subset: character(1)
#'   Glyph subset to request (default: "latin").
#' @typedreturn list
#'   Invisibly returns a list with paths for `regular`, `italic`, `bold`
#'   and `bolditalic` variants, or throws an error on failure.
#' @export
add_font <- function(
  name,
  provider = "bunny",
  family = NULL,
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin"
) {
  #------ Arg check
  assert_null_or_non_empty_string(name, allow_null = FALSE)
  assert_null_or_non_empty_string(provider, allow_null = FALSE)
  assert_null_or_non_empty_string(family, allow_null = TRUE)

  if (!is.numeric(regular.wt) || length(regular.wt) != 1) {
    cli::cli_abort("{.arg regular.wt} must be a single numeric weight.")
  }
  if (!is.numeric(bold.wt) || length(bold.wt) != 1) {
    cli::cli_abort("{.arg bold.wt} must be a single numeric weight.")
  }
  assert_null_or_non_empty_string(subset, allow_null = FALSE)

  #------ Prepare identifiers and provider
  provider_obj <- get_provider_details(provider)
  font_id <- safe_id(name)
  family_name <- if (is.null(family)) name else family
  cache_dir <- get_cache_dir()

  #------ Try to use cached version
  # Attempt to read cache (handle errors gracefully)
  cel <- cache_read(cache_dir = cache_dir)

  # Look for existing cache entry
  ceexisting_entry <- NULL
  if (length(cel@entries) > 0) {
    got <- cache_get(cel, families = family_name, quiet = TRUE)
    if (!is.null(got) && length(got) >= 1) {
      existing_entry <- got[[1]]
    }
  }

  # If found, try to register from cache
  if (!is.null(existing_entry)) {
    files <- register_from_cache(existing_entry)
    if (!is.null(files)) {
      return(invisible(files))
    }

    # Stale cache entry: remove and continue to re-download
    cli::cli_warn(
      "Stale cache entry for {.val {family_name}} — re-downloading."
    )
    cel <- cache_remove(
      cel,
      families = family_name,
      remove_files = FALSE,
      cache_dir = cache_dir
    )
    cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
  }

  #------ Download, convert, and register
  files_entry <- register_from_download(
    provider = provider_obj,
    name = name,
    font_id = font_id,
    family_name = family_name,
    regular.wt = regular.wt,
    bold.wt = bold.wt,
    subset = subset,
    cache_dir = cache_dir
  )

  if (is.null(files_entry)) {
    cli::cli_abort(
      "Failed to obtain font {.val {name}} from provider {.val {provider}}."
    )
  }

  invisible(files_entry)
}
