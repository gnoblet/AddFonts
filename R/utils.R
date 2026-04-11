#' Delete files
#'
#' Attempt to delete a set of files (character vector or list of paths).
#'
#' @typed entries: character
#'   Character vector of file paths to remove.
#' @typed quiet: logical(1)
#'   If `TRUE`, suppress all console messages. If `FALSE`, show success and
#'   failure messages (default: `FALSE`).

#' @typedreturn list
#'   A list with the following elements:
#'
#'   - deleted: character() — paths successfully deleted
#'   - failed: character() — paths that existed but could not be deleted
#'   - not_found: character() — paths that were not found on disk
#'
#' @export
delete_files <- function(
  entries,
  quiet = FALSE
) {
  #------ Arg check

  # entries is a character vector
  assert_null_or_non_empty_character_vector(entries)

  if (!is.logical(quiet) || length(quiet) != 1) {
    cli::cli_abort("{.arg quiet} must be a logical scalar.")
  }

  #------ Do stuff

  # normalize entries to character vector
  files <- fs::path_expand(entries)
  files <- files[nzchar(files)]

  # init result vectors
  deleted <- character()
  not_found <- character()
  failed <- character()

  # attempt to delete each file
  for (f in files) {
    if (!fs::file_exists(f)) {
      not_found <- c(not_found, f)
      next
    }

    ok <- tryCatch(
      {
        fs::file_delete(f)
        TRUE
      },
      error = function(e) FALSE
    )

    if (isTRUE(ok) && !fs::file_exists(f)) {
      deleted <- c(deleted, f)
    } else {
      failed <- c(failed, f)
    }
  }

  if (!quiet && length(deleted) > 0) {
    cli::cli_alert_success("Deleted {length(deleted)} file{?s}:")
    lapply(deleted, function(x) cli::cli_text("  - {.file {x}}"))
  }

  if (!quiet && (length(failed) > 0 || length(not_found) > 0)) {
    if (length(failed) > 0) {
      cli::cli_alert_danger("Failed to delete {length(failed)} file{?s}:")
      lapply(failed, function(x) cli::cli_text("  - {.file {x}}"))
    }
    if (length(not_found) > 0) {
      cli::cli_alert_info("{length(not_found)} file{?s} not found:")
      lapply(not_found, function(x) cli::cli_text("  - {.file {x}}"))
    }
  }

  invisible(list(deleted = deleted, failed = failed, not_found = not_found))
}

#' Create a filesystem-safe id from a name
#'
#' Replace disallowed characters with `-` and convert to lower-case so
#' the resulting id is safe to use in filenames.
#'
#' @typed name: character(1)
#'   Input name to sanitise.
#' @typedreturn character(1)
#'   Sanitised identifier.
safe_id <- function(name) {
  #------ Arg check

  # name is a character string of length 1
  assert_null_or_non_empty_string(name, allow_null = FALSE)

  #------ Do stuff
  gsub("[^a-z0-9-]", "-", tolower(name))
}

## Utilities: get_cache_dir
#' Get the package cache directory for fonts
#'
#' Determine a platform-appropriate cache directory for AddFonts and
#' ensure it exists, creating it when necessary.
#'
#' @typedreturn character(1)
#'   Absolute path to the cache directory.
get_cache_dir <- function() {
  #------ Arg checks
  # no arguments to validate for this helper

  #------ Implementation
  # Use rappdirs to get a platform-appropriate user cache dir for AddFonts
  cache_dir <- rappdirs::user_cache_dir("AddFonts")

  # Ensure the directory exists; create it if missing
  if (!fs::dir_exists(cache_dir)) {
    fs::dir_create(cache_dir, recurse = TRUE)
    cli::cli_alert_info("Created font cache directory: {.file {cache_dir}}")
  }

  cache_dir
}

## Utilities: get_provider_details
#' Get provider details from internal data
#'
#' Load and return a FontProvider object for the specified provider.
#' The providers data is stored in the package's internal sysdata.rda.
#'
#' @typed provider: character(1)
#'   Provider id/name (e.g. "bunny").
#'
#' @typedreturn FontProvider
#'   A validated FontProvider object.
get_provider_details <- function(provider) {
  #------ Arg check
  assert_null_or_non_empty_string(provider, allow_null = FALSE)

  #------ Do stuff
  # Load providers from internal data (created by data-raw/providers.R)
  # The 'providers' object is stored in R/sysdata.rda
  if (!exists("providers", mode = "list", envir = asNamespace("AddFonts"))) {
    cli::cli_abort(c(
      "!" = "Internal providers data not found.",
      "i" = "Please rebuild the package or check data-raw/providers.R"
    ))
  }

  providers_data <- get("providers", envir = asNamespace("AddFonts"))

  # Check if provider exists in the data
  if (!provider %in% names(providers_data)) {
    available <- paste(names(providers_data), collapse = ", ")
    cli::cli_abort(c(
      "!" = "Provider {.val {provider}} not found.",
      "i" = "Available providers: {.val {available}}"
    ))
  }

  # Convert to FontProvider object and return
  as_FontProvider(providers_data[[provider]])
}
