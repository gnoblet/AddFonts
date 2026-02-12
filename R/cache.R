#' @importFrom jsonlite read_json write_json
NULL

#' Write CacheEntryList to disk as JSON
#'
#' @typed x: CacheEntryList
#'   The CacheEntryList object to write to disk.
#' @typed cache_dir: character(1)
#'   The cache directory to write to (default: NULL).
#' @typed quiet: logical(1)
#'  Whether to suppress output messages (default: TRUE).
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
#' @typed cache_dir: character | NULL
#'   Cache directory to use. Use [get_cache_dir()] to get the default cache directory.
#'
#' @typedreturn CacheEntryList
#'   The cache index as a <CacheEntryList> if found and valid.
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
S7::method(cache_read, S7::class_character | NULL) <- function(
  cache_dir
) {
  #------ Arg check

  # cache_dir is NULL or a path
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

  #------ Do stuff

  # get cache dir path if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

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

  return(cel)
}

#' Get certain families from CacheEntryList
#'
#' @typed x: CacheEntryList
#'   The CacheEntryList object to query.
#' @typed families: character vector
#'   The family names to retrieve.
#' @typed quiet: logical(1)
#'   If TRUE, suppress informational messages (default: TRUE).
#'
#' @typedreturn list
#'  A list of CacheEntry objects matching the specified families. If no families
#'
#' @family cache
#'
cache_get <- S7::new_generic(
  "cache_get",
  "x",
  function(x, families = NULL, quiet = TRUE) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_get
#' @name cache_get
S7::method(cache_get, CacheEntryList) <- function(
  x,
  families = NULL,
  quiet = TRUE
) {
  #------ Arg check

  # families is NULL or a character vector
  assert_null_or_non_empty_character_vector(
    families,
    allow_null = TRUE
  )

  # quiet is a logical(1)
  if (!is.logical(quiet) || length(quiet) != 1) {
    cli::cli_abort("`quiet` must be a logical scalar.")
  }

  #------ Do stuff

  # get entries property
  entries <- x@entries

  # if no families specified, return all
  if (is.null(families)) {
    return(entries)
  }

  # lookup each family in @family property
  # 1. get all family names in entries
  get_entries <- function(entries, families = NULL) {
    if (is.null(families)) {
      return(entries)
    }

    entries_fams <- vapply(entries, function(e) e@family, character(1))
    idx <- match(families, entries_fams, nomatch = 0L)

    if (!quiet) {
      if (all(idx == 0L)) {
        cli::cli_alert_info(
          "No matching families found in cache. Return NULL."
        )
      } else if (any(idx == 0L)) {
        cli::cli_alert_info(c(
          "Some of the specified families were not found: {.val {paste(families[idx == 0L], collapse = ', ')}}"
        ))
      }
    }

    entries[idx[idx > 0L]]
  }
  res <- get_entries(entries, families)
  if (length(res) == 0) {
    return(NULL)
  }

  return(res)
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

  # family is a non-empty string
  assert_null_or_non_empty_string(family, allow_null = FALSE)

  # meta is a CacheMeta object
  if (!S7::S7_inherits(meta, class = CacheMeta)) {
    cli::cli_abort("`meta` must be a <CacheMeta> object.")
  }

  #------ Do stuff

  # create CacheEntry
  ce <- CacheEntry(
    family = family,
    meta = meta
  )

  # get entries
  got <- cache_get(x, families = family)

  # if family exists, replace entry
  if (!is.null(got)) {
    idx <- which(
      vapply(x@entries, function(e) e@family, character(1)) == family
    )
    x@entries[[idx]] <- ce
  } else {
    # else, append entry
    x@entries <- c(x@entries, list(ce))
  }

  return(x)
}

#' Delete entry from cache
#'
#' @typed x: CacheEntryList
#'   The CacheEntryList object to modify.
#' @typed families: character | NULL
#'   The font families to delete. If NULL, all entries are deleted.
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
  function(x, families = NULL, remove_files = TRUE, cache_dir = NULL) {
    S7::S7_dispatch()
  }
)

#' @rdname cache_remove
#' @name cache_remove
S7::method(cache_remove, CacheEntryList) <- function(
  x,
  families = NULL,
  remove_files = TRUE,
  cache_dir = NULL
) {
  #------ Arg check

  # family is NULL or a character vector
  assert_null_or_non_empty_character_vector(
    families,
    allow_null = TRUE
  )

  # remove_files is a logical(1)
  if (!is.logical(remove_files) || length(remove_files) != 1) {
    cli::cli_abort("{.arg remove_files} must be a logical(1).")
  }

  # cache_dir is character(1) or NULL
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

  #------ Do stuff

  # get cache dir path if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  # get entries and family names
  entries <- x@entries
  fams <- vapply(entries, function(e) e@family, character(1))

  # if families is NULL, remove all entries
  if (is.null(families)) {
    res <- list()
  } else {
    # else remove specified familie
    idx <- which(!(fams %in% families))
    res <- entries[idx]
  }

  # remove files from disk if requested
  if (remove_files) {
    # get families to remove
    if (is.null(families)) {
      fams_to_remove <- fams
    } else {
      fams_to_remove <- intersect(fams, families)
    }
    for (fam in fams_to_remove) {
      files <- cache_get(x, families = fam)[[1]]@meta@files |> unlist()
      if (!is.null(files) && length(files) > 0) {
        delete_files(fs::path(cache_dir, files), quiet = "none")
      } else {
        cli::cli_alert_info(
          "No files to remove for family {.val {fam}}."
        )
      }
    }
  }

  # set entries to remaining entries
  x@entries <- res

  return(x)
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
#' @typed ...: anyD
#'   Additional arguments (currently unused).
#'
#' @typedreturn character | NULL
#'   Invisibly returns character vector of removed family names when deleting specific entries, or `NULL` when nothing changed. Remove files by default.
#'
#' @family cache
#'
#' @export
cache_clean <- S7::new_generic(
  "cache_clean",
  "cache_dir",
  function(
    cache_dir = NULL,
    families = NULL,
    reset = FALSE,
    ...
  ) {
    S7::S7_dispatch()
  }
)

# #' @rdname cache_clean
# #' @name cache_clean
# #' @export
# S7::method(cache_clean, NULL) <- function(
#     cache_dir
# ) {}

#' @rdname cache_clean
#' @name cache_clean
#' @export
S7::method(cache_clean, S7::class_character | NULL) <- function(
  cache_dir,
  families = NULL,
  reset = FALSE
) {
  #------ Arg check

  # families is a character vector or NULL
  assert_null_or_non_empty_character_vector(
    families,
    allow_null = TRUE
  )

  # cache_dir is NULL or a path
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

  # reset is a logical(1)
  if (!is.logical(reset) || length(reset) != 1) {
    cli::cli_abort("`reset` must be a logical scalar.")
  }

  #------ Do stuff

  # get cache dir path if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  # if reset, delete whole cache dir
  if (reset) {
    if (dir.exists(cache_dir)) {
      # delete cache dir
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

  # write empty cache
  cache_write(cel_new, cache_dir = cache_dir, quiet = TRUE)

  # aler user for success
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
  available <- weight_keys %in% cached_weight_keys

  return(available)
}
