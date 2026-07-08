#' @importFrom jsonlite read_json write_json
NULL

#' Write CacheEntryList to disk as JSON
#'
#' @typed x: CacheEntryList
#'   The CacheEntryList object to write to disk.
#' @typed cache_dir: character(1)
#'   The cache directory to write to (default: NULL).
#' @typed quiet: logical(1)
#'   Whether to suppress output messages (default: TRUE).
#'
#' @family cache
#'
#' @typedreturn NULL
#'  Invisibly returns NULL.
#'
cache_write <- S7::new_generic(
  "cache_write",
  "x",
  function(x, cache_dir = NULL, quiet = TRUE) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_write
#' @name cache_write
S7::method(cache_write, CacheEntryList) <- function(
  x,
  cache_dir = NULL,
  quiet = TRUE
) {
  #------ Arg check

  # cache_dir is NULL or a path
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

  # quiet is a logical(1)
  if (!is.logical(quiet) || length(quiet) != 1) {
    cli::cli_abort("`quiet` must be a logical scalar.")
  }

  # get cache dir path if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
    # create cache dir if it does not exist
    if (!fs::dir_exists(cache_dir)) {
      fs::dir_create(cache_dir, recurse = TRUE)
    }
  } else {
    # check if it exists
    if (!fs::dir_exists(cache_dir)) {
      cli::cli_abort(
        "The specified cache directory does not exist: {.val {cache_dir}}. Use either default (NULL) or create the directory first."
      )
    }
  }

  # convert to list
  l <- as_list(x)

  # write index file
  cache_file <- fs::path(cache_dir, "fonts_db.json")

  # write to json
  jsonlite::write_json(
    x = l,
    path = cache_file,
    auto_unbox = TRUE,
    pretty = TRUE
  )

  # alert for success
  if (!quiet) {
    if (fs::file_exists(cache_file)) {
      cli::cli_alert_success(
        "Cache index written to {.file {cache_file}}."
      )
    } else {
      cli::cli_alert_danger(
        "Failed to write cache index to {.file {cache_file}}."
      )
    }
  }

  invisible(NULL)
}

#' Read cache entry from disk
#'
#' @typed cache_dir: character(1)
#'   Cache directory path. Must not be NULL. Use `cache_read_safe()` for a  NULL-tolerant variant that returns an empty index on error.
#'
#' @typedreturn CacheEntryList
#'   The cache index as a CacheEntryList if found and valid.
#'
#' @family cache
#'
cache_read <- S7::new_generic(
  "cache_read",
  "cache_dir",
  function(cache_dir) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_read
#' @name cache_read
S7::method(cache_read, S7::class_character) <- function(cache_dir) {
  #------ Arg check
  assert_null_or_non_empty_string(cache_dir, allow_null = FALSE)

  #------ Do stuff

  # read index file
  cache_file <- fs::path(cache_dir, "fonts_db.json")
  if (!fs::file_exists(cache_file)) {
    cli::cli_abort(
      "Cache file does not exist: {.val {cache_file}}"
    )
  }
  raw <- jsonlite::read_json(cache_file, simplifyVector = FALSE)
  # try to parse as CacheEntryList, if not possible abort
  cel <- tryCatch(
    as_CacheEntryList(raw),
    error = function(e) {
      cli::cli_abort(c(
        "The cache index file at {.file {cache_file}} is corrupted or unreadable",
        "x" = "Cannot parse as <CacheEntryList>: {.emph {e$message}}",
        "i" = "Run `cache_clean(reset = TRUE)` to reset the cache."
      ))
    }
  )

  cel
}

#' Get certain families from CacheEntryList
#'
#' @typed x: CacheEntryList
#'   The CacheEntryList object to query.
#' @typed families: character vector
#'   The family names to retrieve.
#' @typed source: character(1) | NULL
#'   If provided, look up by exact compound `"{source}::{family}"` key (fast). If `NULL`, scan all entries and match on family name alone (default: NULL).
#' @typed quiet: logical(1)
#'   If TRUE, suppress informational messages (default: TRUE).
#'
#' @typedreturn list
#'  A list of CacheEntry objects matching the specified families, or NULL.
#'
#' @family cache
#'
cache_get <- S7::new_generic(
  "cache_get",
  "x",
  function(x, families = NULL, source = NULL, quiet = TRUE) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_get
#' @name cache_get
S7::method(cache_get, CacheEntryList) <- function(
  x,
  families = NULL,
  source = NULL,
  quiet = TRUE
) {
  #------ Arg check
  assert_null_or_non_empty_character_vector(families, allow_null = TRUE)
  assert_null_or_non_empty_string(source, allow_null = TRUE)
  if (!is.logical(quiet) || length(quiet) != 1) {
    cli::cli_abort("`quiet` must be a logical scalar.")
  }

  #------ Do stuff
  entries <- x@entries

  if (is.null(families)) {
    return(entries)
  }

  if (!is.null(source)) {
    # Exact compound-key lookup: O(1) per family
    keys <- paste0(source, "::", families)
    found <- entries[keys[keys %in% names(entries)]]
  } else {
    # Scan by family name (works even for unnamed/legacy entries)
    found <- entries[vapply(
      entries,
      function(e) e@family %in% families,
      logical(1)
    )]
  }

  if (length(found) == 0) {
    if (!quiet) {
      cli::cli_alert_info("No matching families found in cache.")
    }
    return(NULL)
  }

  if (!quiet && length(found) < length(families)) {
    missing_fams <- setdiff(
      families,
      vapply(found, function(e) e@family, character(1))
    )
    cli::cli_alert_info(
      "Some families were not found in cache: {.val {missing_fams}}"
    )
  }

  found
}

#' Set cache entries
#'
#' @typed x: CacheEntryList
#'  The CacheEntryList object to modify.
#' @typed family: character(1)
#'  The font family to modify.
#' @typed meta: CacheMeta
#'  The new metadata to set.
#'
#' @typedreturn CacheEntryList
#'  The modified CacheEntryList with the updated entry.
#'
cache_set <- S7::new_generic(
  "cache_set",
  "x",
  function(x, family, meta) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_set
#' @name cache_set
S7::method(cache_set, CacheEntryList) <- function(
  x,
  family,
  meta
) {
  #------ Arg check
  assert_null_or_non_empty_string(family, allow_null = FALSE)
  if (!S7::S7_inherits(meta, class = CacheMeta)) {
    cli::cli_abort("`meta` must be a <CacheMeta> object.")
  }

  #------ Do stuff: named-list upsert by compound key
  key <- paste0(meta@source, "::", family)
  x@entries[[key]] <- CacheEntry(family = family, meta = meta)

  x
}

#' Delete entry from cache
#'
#' @typed x: CacheEntryList
#'   The CacheEntryList object to modify.
#' @typed families: character | NULL
#'   The font families to delete. If NULL, all entries are deleted.
#' @typed source: character(1) | NULL
#'   If provided, remove only the entry for `"{source}::{family}"`. If NULL,
#'   remove all entries whose family name matches, regardless of source.
#' @typed remove_files: logical(1)
#'  If `TRUE` attempt to delete files referenced by removed entries (default: TRUE).
#' @typed cache_dir: character(1) | NULL
#'  The cache directory to delete from. If NULL, the default cache directory is used.
#'
#' @family cache
#'
#' @typedreturn CacheEntryList
#'  The modified CacheEntryList with the specified entries removed.
#'
cache_remove <- S7::new_generic(
  "cache_remove",
  "x",
  function(
    x,
    families = NULL,
    source = NULL,
    remove_files = TRUE,
    cache_dir = NULL
  ) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_remove
#' @name cache_remove
S7::method(cache_remove, CacheEntryList) <- function(
  x,
  families = NULL,
  source = NULL,
  remove_files = TRUE,
  cache_dir = NULL
) {
  #------ Arg check
  assert_null_or_non_empty_character_vector(families, allow_null = TRUE)
  assert_null_or_non_empty_string(source, allow_null = TRUE)
  if (!is.logical(remove_files) || length(remove_files) != 1) {
    cli::cli_abort("{.arg remove_files} must be a logical(1).")
  }
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

  #------ Do stuff
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  entries <- x@entries

  # Determine which keys to remove
  if (is.null(families)) {
    keys_to_remove <- names(entries)
  } else if (!is.null(source)) {
    # Exact compound-key removal
    candidate_keys <- paste0(source, "::", families)
    keys_to_remove <- candidate_keys[candidate_keys %in% names(entries)]
  } else {
    # Remove all entries whose @family matches, any source
    keys_to_remove <- names(entries)[
      vapply(entries, function(e) e@family %in% families, logical(1))
    ]
  }

  # Delete files from disk if requested
  if (remove_files) {
    for (key in keys_to_remove) {
      entry <- entries[[key]]
      if (is.null(entry)) {
        next
      }
      files <- unlist(entry@meta@files)
      if (length(files) > 0) {
        delete_files(fs::path(cache_dir, files), quiet = FALSE)
      } else {
        cli::cli_alert_info(
          "No files to remove for {.val {key}}."
        )
      }
    }
  }

  x@entries[keys_to_remove] <- NULL
  x
}

#' Clean cache entries
#'
#' Remove entries from the cache, optionally unlinking referenced files.
#'
#' @typed cache_dir: NULL | character(1)
#'   Cache directory to use (default: NULL)
#' @typed families: character | NULL
#'   Character vector of family names to remove, or `NULL` to clear the whole cache (default: NULL)
#' @typed reset: logical(1)
#'   If TRUE, completely reset and clear the cache (default: FALSE).
#'
#' @typedreturn character | NULL
#'   Invisibly returns character vector of removed family names when deleting specific entries, or `NULL` when nothing changed. Remove files by default.
#'
#' @family cache
#'
#' @export
cache_clean <- function(cache_dir = NULL, families = NULL, reset = FALSE) {
  #------ Arg check

  # families is a character vector or NULL
  assert_null_or_non_empty_character_vector(families, allow_null = TRUE)

  # cache_dir is NULL or a path
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

  # reset is a logical(1)
  if (!is.logical(reset) || length(reset) != 1) {
    cli::cli_abort("{.arg reset} must be a logical scalar.")
  }

  #------ Do stuff

  # get cache dir path if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  # if reset, delete whole cache dir
  if (reset) {
    if (fs::dir_exists(cache_dir)) {
      fs::dir_delete(cache_dir)
    } else {
      cli::cli_alert_info(
        "Cache directory {.path {cache_dir}} does not exist, nothing to reset."
      )
    }
    # create cache_dir and database with empty cache
    fs::dir_create(cache_dir)
    cache_write(
      CacheEntryList(entries = list()),
      cache_dir = cache_dir,
      quiet = TRUE
    )
    cli::cli_alert_success("Cache reset.")
    return(invisible(NULL))
  }

  # read cache
  cel <- cache_read(cache_dir)

  # return early if empty already
  if (length(cel@entries) == 0) {
    cli::cli_alert_info("Cache is already empty.")
    return(invisible(NULL))
  }

  # remove entries
  cel_new <- cache_remove(
    cel,
    families = families,
    remove_files = TRUE,
    cache_dir = cache_dir
  )

  # write updated cache
  cache_write(cel_new, cache_dir = cache_dir, quiet = TRUE)

  cli::cli_alert_success("Cache cleared.")

  invisible(NULL)
}

#' Check which weights are available in a cache entry
#'
#' @typed entry: CacheEntry
#'   The CacheEntry object to check.
#' @typed weights: numeric
#'   Vector of weights to check for availability.
#'
#' @typedreturn lgl
#'  Logical vector indicating which weights are cached).
#'
#' @family cache
#'
cache_get_weights <- S7::new_generic(
  "cache_get_weights",
  "entry",
  function(entry, weights) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_get_weights
#' @name cache_get_weights
S7::method(cache_get_weights, CacheEntry) <- function(entry, weights) {
  #------ Arg check

  if (!is.numeric(weights) || length(weights) == 0) {
    cli::cli_abort("{.arg weights} must be a non-empty numeric vector.")
  }

  #------ Do stuff
  cached_files <- entry@meta@files
  cached_weight_keys <- names(cached_files)

  # Build keys for requested weights
  weight_keys <- as.character(weights)

  # Check which weights are available
  weight_keys %in% cached_weight_keys
}

#' Check which symbolic variant keys are present in a CacheEntry
#'
#' Used for file-based providers whose `CacheMeta@files` uses the key `"regular"`, `"italic"`, `"bold"`, `"bolditalic"` instead of numeric weight strings.
#'
#' @typed entry: CacheEntry
#'   The cache entry to inspect.
#' @typed variants: character
#'   Character vector of symbolic variant names to check.
#'
#' @typedreturn lgl
#'   Named logical vector indicating which variants are cached.
#'
#' @family cache
#'
cache_get_variants <- S7::new_generic(
  "cache_get_variants",
  "entry",
  function(entry, variants) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_get_variants
#' @name cache_get_variants
S7::method(cache_get_variants, CacheEntry) <- function(entry, variants) {
  if (!is.character(variants) || length(variants) == 0) {
    cli::cli_abort("{.arg variants} must be a non-empty character vector.")
  }

  cached_keys <- names(entry@meta@files)
  stats::setNames(variants %in% cached_keys, variants)
}

# Read cache from disk, returning an empty CacheEntryList on any error. Internal helper used wherever a missing/corrupt cache should not abort.
cache_read_safe <- function(cache_dir = NULL) {
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }
  tryCatch(
    cache_read(cache_dir),
    error = function(e) as_CacheEntryList(list())
  )
}
