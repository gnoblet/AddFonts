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
#'
#' @typedreturn CacheEntry
#'   The newly created cache entry.
#'
.persist_cache_entry <- function(source, family_name, files_entry, cache_dir) {
  meta <- CacheMeta(source = source, files = files_entry)
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

#' Route add_font() for a weight-based provider
#'
#' Handles the full cache-check → optional partial update-download-register cycle for `FontProviderWeight` providers.
#'
#' @typed provider_obj: FontProviderWeight
#'   Weight-based provider object.
#' @typed name: character(1)
#'   Font name at the provider.
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed regular.wt: numeric(1)
#'   Regular weight to request.
#' @typed bold.wt: numeric(1)
#'   Bold weight to request.
#' @typed subset: character(1)
#'   Glyph subset to request.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
.add_font_weight <- function(
  provider_obj,
  name,
  family_name,
  regular.wt,
  bold.wt,
  subset,
  cache_dir
) {
  if (!is.numeric(regular.wt) || length(regular.wt) != 1) {
    cli::cli_abort("{.arg regular.wt} must be a single numeric weight.")
  }
  if (!is.numeric(bold.wt) || length(bold.wt) != 1) {
    cli::cli_abort("{.arg bold.wt} must be a single numeric weight.")
  }
  assert_null_or_non_empty_string(subset, allow_null = FALSE)

  res <- .cache_lookup(cache_dir, family_name, provider_obj@source)
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    weight_check <- cache_get_weights(existing_entry, c(regular.wt, bold.wt))
    has_regular <- weight_check[1]
    has_bold <- weight_check[2]

    if (has_regular && has_bold) {
      files <- register_from_cache(
        existing_entry,
        regular.wt = regular.wt,
        bold.wt = bold.wt
      )
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn(
        "Stale cache entry for {.val {family_name}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    } else if (has_regular && !has_bold) {
      cli::cli_inform(
        "Cached {.val {family_name}} has regular weight {.val {regular.wt}}. Downloading missing bold weight {.val {bold.wt}}."
      )
      updated_entry <- update_download_and_cache(
        entry = existing_entry,
        provider = provider_obj,
        name = name,
        family_name = family_name,
        missing_weights = bold.wt,
        subset = subset,
        cache_dir = cache_dir,
        cel = cel
      )
      if (!is.null(updated_entry)) {
        files <- register_from_cache(
          updated_entry,
          regular.wt = regular.wt,
          bold.wt = bold.wt
        )
        if (!is.null(files)) {
          cli::cli_alert_success(
            "Font {.val {family_name}} registered with updated weights from cache."
          )
          return(invisible(files))
        }
      }
      cli::cli_warn(
        "Failed to download missing weight or register - re-downloading all weights."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    } else {
      cli::cli_inform(
        "Cached {.val {family_name}} is missing requested regular weight {.val {regular.wt}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache(
    provider = provider_obj,
    name = name,
    family_name = family_name,
    regular.wt = regular.wt,
    bold.wt = bold.wt,
    subset = subset,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort(
      "Failed to obtain font {.val {name}} from provider {.val {provider_obj@source}}."
    )
  }

  files <- register_from_cache(
    cache_entry,
    regular.wt = regular.wt,
    bold.wt = bold.wt
  )
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}

#' Route add_font() for a file-based provider
#'
#' Handles the cache-check → download → register cycle for `FontProviderFile` providers using symbolic variant keys.
#'
#' @typed provider_obj: FontProviderFile
#'   File-based provider object.
#' @typed name: character(1)
#'   Font name at the provider (used as `{family}` in the URL template).
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to filename stems.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
.add_font_file <- function(
  provider_obj,
  name,
  family_name,
  variants,
  cache_dir
) {
  .validate_variants(variants)

  res <- .cache_lookup(cache_dir, family_name, provider_obj@source)
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    variant_check <- cache_get_variants(existing_entry, "regular")
    if (isTRUE(variant_check[["regular"]])) {
      files <- register_from_cache(existing_entry)
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn(
        "Stale cache entry for {.val {family_name}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = provider_obj@source,
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache_file(
    provider = provider_obj,
    name = name,
    family_name = family_name,
    variants = variants,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort(
      "Failed to obtain font {.val {name}} from provider {.val {provider_obj@source}}."
    )
  }

  files <- register_from_cache(cache_entry)
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}

#' Route add_font() for provider = "file" (local copies)
#'
#' Handles the cache-check → copy → register cycle when the user supplies `provider = "file"`. Uses source key `"file"` in the cache index.
#'
#' @typed name: character(1)
#'   Font name (used as the family component of cache filenames).
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to absolute local file paths.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
.add_font_local <- function(name, family_name, variants, cache_dir) {
  .validate_variants(variants)

  res <- .cache_lookup(cache_dir, family_name, "file")
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    variant_check <- cache_get_variants(existing_entry, "regular")
    if (isTRUE(variant_check[["regular"]])) {
      files <- register_from_cache(existing_entry)
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn("Stale cache entry for {.val {family_name}} - re-copying.")
      cel <- cache_remove(
        cel,
        families = family_name,
        source = "file",
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- copy_and_cache_local(
    name = name,
    family_name = family_name,
    variants = variants,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort("Failed to copy font {.val {name}} to cache.")
  }

  files <- register_from_cache(cache_entry)
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}

#' Route add_font() for provider = "url" (direct download)
#'
#' Handles the cache-check → download → register cycle when the user supplies `provider = "url"`. Uses source key `"url"` in the cache index.
#'
#' @typed name: character(1)
#'   Font name (used as the family component of cache filenames).
#' @typed family_name: character(1)
#'   Family name to register the font under.
#' @typed variants: list
#'   Named list mapping symbolic variant keys to full download URLs.
#' @typed cache_dir: character(1)
#'   Cache directory path.
#'
#' @typedreturn list
#'   Invisibly, a named list of local file paths for all registered variants.
#'
.add_font_direct_url <- function(name, family_name, variants, cache_dir) {
  .validate_variants(variants)

  res <- .cache_lookup(cache_dir, family_name, "url")
  cel <- res$cel
  existing_entry <- res$entry

  if (!is.null(existing_entry)) {
    variant_check <- cache_get_variants(existing_entry, "regular")
    if (isTRUE(variant_check[["regular"]])) {
      files <- register_from_cache(existing_entry)
      if (!is.null(files)) {
        cli::cli_alert_success(
          "Font {.val {family_name}} registered from cache."
        )
        return(invisible(files))
      }
      cli::cli_warn(
        "Stale cache entry for {.val {family_name}} - re-downloading."
      )
      cel <- cache_remove(
        cel,
        families = family_name,
        source = "url",
        remove_files = FALSE,
        cache_dir = cache_dir
      )
      cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }
  }

  cache_entry <- download_and_cache_url(
    name = name,
    family_name = family_name,
    variants = variants,
    cache_dir = cache_dir
  )
  if (is.null(cache_entry)) {
    cli::cli_abort("Failed to download font {.val {name}} from URL.")
  }

  files <- register_from_cache(cache_entry)
  if (!is.null(files)) {
    cli::cli_alert_success(
      "Font {.val {family_name}} registered and added to cache."
    )
  }
  invisible(files)
}
