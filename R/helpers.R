#' Validate a variants list
#'
#' Checks that `variants` is a non-`NULL` named list whose names are a subset of the recognised symbolic keys and contains at least `"regular"`. Aborts with an informative error on the first violation found.
#'
#' @typed variants: list
#'   Named list of symbolic variant keys to font-specific values (filename stems, absolute paths, or URLs depending on the caller).
#'
#' @typedreturn NULL
#'   Returns `invisible(NULL)` on success; called for its side-effect.
#'
.validate_variants <- function(variants) {
  valid <- c("regular", "italic", "bold", "bolditalic")
  if (!is.list(variants) || is.null(names(variants))) {
    cli::cli_abort("{.arg variants} must be a named list.")
  }
  bad <- setdiff(names(variants), valid)
  if (length(bad) > 0) {
    cli::cli_abort("Unknown variant name{?s} in {.arg variants}: {.val {bad}}.")
  }
  if (!"regular" %in% names(variants)) {
    cli::cli_abort("{.arg variants} must include a {.val regular} entry.")
  }
  invisible(NULL)
}

#' Build a CacheEntry, persist the cache index, and return the entry
#'
#' Constructs a [CacheMeta()] and a [CacheEntry()], upserts the entry into the on-disk cache index via `cache_read_safe()`, [cache_set()], and [cache_write()], then returns the new entry. This is the shared persist tail used by all download/copy orchestrators.
#'
#' @typed source: character(1)
#'   Provider source identifier (e.g. `"bunny"`, `"file"`, `"url"`).
#' @typed family_name: character(1)
#'   Family identifier to register the entry under.
#' @typed files_entry: list
#'   Named list of variant-key to local file path mappings.
#' @typed cache_dir: character(1)
#'   Path to the cache directory.
#' @typed failed_keys: character(0+)
#'  A character vector of keys that were requested but failed to download. Empty if all requested keys were successfully downloaded. (default: character(0))
#'
#' @typedreturn CacheEntry
#'   The newly created cache entry.
#'
.persist_cache_entry <- function(
  source,
  family_name,
  files_entry,
  cache_dir,
  failed_keys = character(0)
) {
  symbolic_keys <- c("regular", "italic", "bold", "bolditalic")
  key_scheme <- if (any(names(files_entry) %in% symbolic_keys)) {
    "symbolic"
  } else {
    "weight"
  }
  meta <- CacheMeta(
    source = source,
    key_scheme = key_scheme,
    files = files_entry,
    failed_keys = failed_keys
  )
  cel <- cache_read_safe(cache_dir)
  cel <- cache_set(cel, family_name, meta)
  cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
  CacheEntry(family = family_name, meta = meta)
}

#' Download a URL to a local file via httr2
#'
#' Issues an HTTP GET for `url`, writing the response body to `local_path`. On failure (httr2 error or missing output file) warns (unless `quiet`) and returns `NULL`.
#'
#' @typed url: character(1)
#'   Full URL to fetch.
#' @typed local_path: character(1)
#'   Destination path for the downloaded file.
#' @typed family: character(1)
#'   Font family name — used in warning messages only.
#' @typed variant: character(1)
#'   Variant key — used in warning messages only.
#' @typed quiet: logical(1)
#'   Suppress warnings and messages.
#'
#' @typedreturn character | NULL
#'   `local_path` on success, or `NULL` on failure.
#'
.fetch_url_to_cache <- function(url, local_path, family, variant, quiet) {
  req <- httr2::request(url) |> httr2::req_user_agent("AddFonts R package")
  resp <- tryCatch(
    httr2::req_perform(req, path = local_path),
    error = function(e) e
  )

  if (inherits(resp, "error") || !fs::file_exists(local_path)) {
    if (!quiet) {
      cli::cli_warn(c(
        "!" = "Download failed for {.val {family}} ({variant})",
        "i" = if (inherits(resp, "error")) resp$message else "No file written",
        "x" = "URL: {.url {url}}"
      ))
    }
    return(NULL)
  }

  if (!quiet) {
    cli::cli_alert_success("Downloaded variant: {.file {basename(local_path)}}")
  }

  local_path
}

#' Read cache and look up an existing entry for a family/source pair
#'
#' Returns both the current `CacheEntryList` and the first matching entry (or `NULL` when absent), so callers can continue to use `cel` for updates.
#'
#' @noRd
.cache_lookup <- function(cache_dir, family_name, source) {
  cel <- cache_read_safe(cache_dir = cache_dir)
  entry <- NULL
  if (length(cel@entries) > 0) {
    got <- cache_get(cel, families = family_name, source = source, quiet = TRUE)
    if (!is.null(got) && length(got) >= 1) entry <- got[[1]]
  }
  list(cel = cel, entry = entry)
}

#' Collect per-variant paths into a named list
#'
#' Iterates over `names(variants)`, calls `fetch_fn(variant)` for each, and collects non-NULL results. Used by all three variant-based download/copy orchestrators to eliminate duplicated loop skeletons.
#'
#' @noRd
.collect_variant_paths <- function(variants, fetch_fn) {
  files <- list()
  for (variant in names(variants)) {
    path <- fetch_fn(variant)
    if (!is.null(path)) files[[variant]] <- path
  }
  files
}
