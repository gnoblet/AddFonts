#' Download all variants of a file-based font and add to cache
#'
#' Downloads each named variant from a [FontProviderFile()] provider, creates a [CacheEntry()] with symbolic keys (`"regular"`, `"italic"`, `"bold"`, `"bolditalic"`), writes the entry to the cache, and returns it.
#'
#' @typed provider: FontProviderFile
#'   A file-based provider object.
#' @typed name: character(1)
#'   Font name as known to the provider (used in URL template as `{family}`).
#' @typed family_name: character(1)
#'   Family name under which to register the font.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to filename stems. Names must be a subset of `c("regular", "italic", "bold", "bolditalic")`. At minimum, `"regular"` must be present. Values are filename stems without extension (e.g. `list(regular = "Alpaga-Regular", bold = "Alpaga-Bold")`).
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL).
#'
#' @typedreturn CacheEntry | NULL
#'   Cache entry with downloaded variants, or `NULL` if the regular variant could not be downloaded.
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
  .validate_variants(variants)

  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  #------ Download each requested variant
  files_entry <- list()

  for (variant in names(variants)) {
    filename <- variants[[variant]]
    path <- download_variant_file(
      provider = provider,
      family = name,
      filename = filename,
      variant = variant,
      cache_dir = cache_dir,
      quiet = FALSE
    )
    if (!is.null(path)) {
      files_entry[[variant]] <- path
    }
  }

  if (!"regular" %in% names(files_entry)) {
    return(NULL)
  }

  .persist_cache_entry(provider@source, family_name, files_entry, cache_dir)
}

#' Download direct-URL font variants and add to cache
#'
#' Downloads each variant from a direct URL, creates a [CacheEntry()] with
#' symbolic keys and source `"url"`, writes the entry to the cache, and
#' returns it.
#'
#' @typed name: character(1)
#'   Font name (used as the family component of cache filenames).
#' @typed family_name: character(1)
#'   Family name under which to register the font.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to full URLs. Names must be a
#'   subset of `c("regular", "italic", "bold", "bolditalic")`. At minimum,
#'   `"regular"` must be present.
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL).
#'
#' @typedreturn CacheEntry | NULL
#'   Cache entry with downloaded variants, or `NULL` if the regular variant
#'   could not be downloaded.
#'
download_and_cache_url <- function(
  name,
  family_name,
  variants,
  cache_dir = NULL
) {
  .validate_variants(variants)

  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  files_entry <- list()

  for (variant in names(variants)) {
    url <- variants[[variant]]
    file_ext <- fs::path_ext(basename(url))
    dest <- cache_file_path("url", name, variant, file_ext, cache_dir)
    path <- .fetch_url_to_cache(url, dest, name, variant, quiet = FALSE)
    if (!is.null(path)) files_entry[[variant]] <- path
  }

  if (!"regular" %in% names(files_entry)) {
    return(NULL)
  }

  .persist_cache_entry("url", family_name, files_entry, cache_dir)
}

#' Copy local font files to cache and create a cache entry
#'
#' Copies each local font file into the cache directory, creates a
#' [CacheEntry()] with symbolic keys and source `"file"`, writes the entry to
#' the cache, and returns it.
#'
#' @typed name: character(1)
#'   Font name (used as the family component of cache filenames).
#' @typed family_name: character(1)
#'   Family name under which to register the font.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to absolute file paths. Names
#'   must be a subset of `c("regular", "italic", "bold", "bolditalic")`. At
#'   minimum, `"regular"` must be present.
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL).
#'
#' @typedreturn CacheEntry | NULL
#'   Cache entry with copied variants, or `NULL` if the regular variant
#'   could not be copied.
#'
copy_and_cache_local <- function(
  name,
  family_name,
  variants,
  cache_dir = NULL
) {
  .validate_variants(variants)

  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  files_entry <- list()

  for (variant in names(variants)) {
    path <- copy_variant_to_cache(
      src_path = variants[[variant]],
      family = name,
      variant = variant,
      cache_dir = cache_dir,
      quiet = FALSE
    )
    if (!is.null(path)) files_entry[[variant]] <- path
  }

  if (!"regular" %in% names(files_entry)) {
    return(NULL)
  }

  .persist_cache_entry("file", family_name, files_entry, cache_dir)
}
