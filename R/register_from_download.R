#' Download necessary variants for a font, write a cache entry and
#' register the font with `sysfonts`. Returns the prepared `files` list
#' on success, or `NULL` if a regular font could not be obtained.
#'
#' @typed provider: FontProvider
#'   Provider object used for downloads.
#' @typed name: character(1)
#'   Font name at the provider.
#' @typed font_id: character(1)
#'   Filesystem-safe font id.
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed regular.wt: integer(1)
#'   Regular weight to fetch (default: 400)
#' @typed bold.wt: integer(1)
#'   Bold weight to fetch (default: 700)
#' @typed subset: character(1)
#'   Glyph subset to request (default: "latin")
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL)
#'
#' @typedreturn list | NULL
#'   List of local file paths for variants, or `NULL` on failure.
#'
register_from_download <- function(
  provider,
  name,
  font_id,
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

  #------ Download variants (regular with warnings, others silent)
  regular_normal <- download_variant_generic(
    provider,
    name,
    regular.wt,
    "normal",
    subset,
    cache_dir,
    quiet = FALSE
  )

  # If regular font not available, cannot proceed
  if (is.null(regular_normal)) {
    return(NULL)
  }

  # Download other variants quietly (fallback if not available)
  regular_italic <- download_variant_generic(
    provider,
    name,
    regular.wt,
    "italic",
    subset,
    cache_dir,
    quiet = TRUE
  )
  bold_normal <- download_variant_generic(
    provider,
    name,
    bold.wt,
    "normal",
    subset,
    cache_dir,
    quiet = TRUE
  )
  bold_italic <- download_variant_generic(
    provider,
    name,
    bold.wt,
    "italic",
    subset,
    cache_dir,
    quiet = TRUE
  )

  #------ Apply fallbacks
  files_entry <- list(
    regular = regular_normal,
    italic = if (!is.null(regular_italic)) regular_italic else regular_normal,
    bold = if (!is.null(bold_normal)) bold_normal else regular_normal,
    bolditalic = if (!is.null(bold_italic)) {
      bold_italic
    } else if (!is.null(bold_normal)) {
      bold_normal
    } else if (!is.null(regular_italic)) {
      regular_italic
    } else {
      regular_normal
    }
  )

  #------ Create cache entry
  meta <- CacheMeta(
    source = provider@source,
    family_id = font_id,
    files = files_entry
  )

  # Read current cache and update it
  cel <- tryCatch(
    cache_read(cache_dir = cache_dir),
    error = function(e) as_CacheEntryList(list())
  )

  cel <- cache_set(cel, family_name, meta)
  cache_write(cel, cache_dir = cache_dir, quiet = TRUE)

  #------ Register with sysfonts
  sysfonts::font_add(
    family = family_name,
    regular = files_entry$regular,
    italic = files_entry$italic,
    bold = files_entry$bold,
    bolditalic = files_entry$bolditalic
  )

  cli::cli_alert_success(
    "Font {.val {family_name}} registered and added to cache."
  )

  return(invisible(files_entry))
}
