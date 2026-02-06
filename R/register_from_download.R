## Helper: register_from_download
##'
##' Download necessary variants for a font, write a registry entry and
##' register the font with `sysfonts`. Returns the prepared `files` list
##' on success, or `NULL` if a regular font could not be obtained.
##'
##' @typed provider: list
##'   Provider details structure used for downloads.
##' @typed name: character(1)
##'   Font name at the provider.
##' @typed font_id: character(1)
##'   Filesystem-safe font id.
##' @typed family_name: character(1)
##'   Family name to register the font under.
##' @typed regular.wt: integer(1)
##'   Regular weight to fetch (default: 400)
##' @typed bold.wt: integer(1)
##'   Bold weight to fetch (default: 700)
##' @typed subset: character(1)
##'   Glyph subset to request (default: "latin")
##' @typed cache_dir: character | NULL
##'   Cache directory to use (default: NULL)
##' @typedreturn list | NULL
##'   List of local file paths for variants, or `NULL` on failure.
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
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  # Fetch primary weight (regular) with visible warnings, rest quiet
  res <- list(
    normal = download_variant_generic(
      provider,
      name,
      regular.wt,
      "normal",
      subset,
      cache_dir,
      quiet = FALSE
    ),
    italic = download_variant_generic(
      provider,
      name,
      regular.wt,
      "italic",
      subset,
      cache_dir,
      quiet = TRUE
    ),
    bold = download_variant_generic(
      provider,
      name,
      regular.wt,
      "bold",
      subset,
      cache_dir,
      quiet = TRUE
    ),
    bolditalic = download_variant_generic(
      provider,
      name,
      regular.wt,
      "bolditalic",
      subset,
      cache_dir,
      quiet = TRUE
    )
  )
  if (is.null(res$italic) && !is.null(res$normal)) {
    res$italic <- res$normal
  }
  if (is.null(res$bold) && !is.null(res$normal)) {
    res$bold <- res$normal
  }
  if (is.null(res$bolditalic) && !is.null(res$italic)) {
    res$bolditalic <- res$italic
  } else if (is.null(res$bolditalic) && !is.null(res$bold)) {
    res$bolditalic <- res$bold
  }

  if (is.null(res$normal)) {
    return(NULL)
  }

  # write registry entry
  files_entry <- list(
    regular = res$normal,
    italic = res$italic,
    bold = res$bold,
    bolditalic = res$bolditalic
  )
  meta <- list(
    source = provider$source,
    family_id = font_id,
    files = files_entry,
    added = as.character(Sys.time())
  )

  # create a validated cache entry and persist
  entry <- new_cache_entry(family_name, meta)
  cache_set(cache_dir, entry$family, entry$meta)

  # register with sysfonts
  sysfonts::font_add(
    family = family_name,
    regular = res$normal,
    italic = res$italic,
    bold = res$bold,
    bolditalic = res$bolditalic
  )

  # notify user for success
  cli::cli_alert_success(
    "Font {.val {family_name}} registered and added to cache."
  )

  return(invisible(files_entry))
}
