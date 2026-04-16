#' Download all variants of a file-based font and add to cache
#'
#' Downloads each named variant from a [FontProviderFile()] provider, creates a
#' [CacheEntry()] with symbolic keys (`"regular"`, `"italic"`, `"bold"`,
#' `"bolditalic"`), writes the entry to the cache, and returns it.
#'
#' @typed provider: FontProviderFile
#'   A file-based provider object.
#' @typed name: character(1)
#'   Font name as known to the provider (used in URL template as `{family}`).
#' @typed family_name: character(1)
#'   Family name under which to register the font.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to filename stems. Names must be
#'   a subset of `c("regular", "italic", "bold", "bolditalic")`. At minimum,
#'   `"regular"` must be present. Values are filename stems without extension
#'   (e.g. `list(regular = "Alpaga-Regular", bold = "Alpaga-Bold")`).
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL).
#'
#' @typedreturn CacheEntry | NULL
#'   Cache entry with downloaded variants, or `NULL` if the regular variant
#'   could not be downloaded.
#'
download_and_cache_file <- function(
  provider,
  name,
  family_name,
  variants,
  cache_dir = NULL
) {
  #------ Arg check
  if (!S7::S7_inherits(provider, FontProviderFile)) {
    cli::cli_abort("{.arg provider} must be a {.cls FontProviderFile} object.")
  }

  valid_variants <- c("regular", "italic", "bold", "bolditalic")
  if (!is.list(variants) || is.null(names(variants))) {
    cli::cli_abort("{.arg variants} must be a named list.")
  }
  bad <- setdiff(names(variants), valid_variants)
  if (length(bad) > 0) {
    cli::cli_abort(
      "Unknown variant name{?s} in {.arg variants}: {.val {bad}}."
    )
  }
  if (!"regular" %in% names(variants)) {
    cli::cli_abort("{.arg variants} must include a {.val regular} entry.")
  }

  if (is.null(cache_dir)) cache_dir <- get_cache_dir()

  #------ Download each requested variant
  files_entry <- list()

  for (variant in names(variants)) {
    filename <- variants[[variant]]
    path <- download_variant_file(
      provider  = provider,
      family    = name,
      filename  = filename,
      variant   = variant,
      cache_dir = cache_dir,
      quiet     = FALSE
    )
    if (!is.null(path)) {
      files_entry[[variant]] <- path
    }
  }

  # Regular variant is mandatory
  if (!"regular" %in% names(files_entry)) {
    return(NULL)
  }

  #------ Build cache entry and persist
  meta <- CacheMeta(
    source = provider@source,
    files  = files_entry
  )

  cel <- cache_read_safe(cache_dir)
  cel <- cache_set(cel, family_name, meta)
  cache_write(cel, cache_dir = cache_dir, quiet = TRUE)

  CacheEntry(
    family = family_name,
    meta   = meta
  )
}
