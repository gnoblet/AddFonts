#' Download one font file from a file-based provider
#'
#' Downloads a single font variant directly from a [FontProviderFile()] using its `base_url` template. No conversion is performed — the file is stored as received.
#'
#' @typed provider: FontProviderFile
#'   A file-based provider object.
#' @typed family: character(1)
#'   Family identifier used in the URL template and cache filename.
#' @typed filename: character(1)
#'   Filename stem (without extension) for the specific variant (e.g. `"Alpaga-Regular"`). Substituted into the `{filename}` placeholder of `provider@base_url`.
#' @typed variant: character(1)
#'   Symbolic key for this variant: one of `"regular"`, `"italic"`, `"bold"`,
#'   `"bolditalic"`.
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL).
#' @typed quiet: logical(1)
#'   Suppress warnings/messages (default: FALSE).
#'
#' @typedreturn character | NULL
#'   Path to the locally cached font file on success, or `NULL` on failure.
#'
download_variant_file <- function(
  provider,
  family,
  filename,
  variant,
  cache_dir = NULL,
  quiet = FALSE
) {
  #------ Arg check
  if (!S7::S7_inherits(provider, FontProviderFile)) {
    cli::cli_abort("{.arg provider} must be a {.cls FontProviderFile} object.")
  }
  assert_null_or_non_empty_string(family, allow_null = FALSE)
  assert_null_or_non_empty_string(filename, allow_null = FALSE)
  assert_null_or_non_empty_string(variant, allow_null = FALSE)

  valid_variants <- c("regular", "italic", "bold", "bolditalic")
  if (!variant %in% valid_variants) {
    cli::cli_abort(
      "{.arg variant} must be one of {.val {valid_variants}}, not {.val {variant}}."
    )
  }

  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  #------ Compute local cache path
  local_path <- cache_file_path(
    source = provider@source,
    family = family,
    variant = variant,
    file_ext = provider@file_ext,
    cache_dir = cache_dir
  )

  #------ Build URL and download
  url <- glue::glue_data(
    list(family = family, filename = filename),
    provider@base_url
  )
  .fetch_url_to_cache(url, local_path, family, variant, quiet)
}

#' Copy one local font file into the cache
#'
#' Copies a local font file into the AddFonts cache directory, naming it according to the standard `"file-{family}-{variant}.{ext}"` convention.
#'
#' @typed src_path: character(1)
#'   Absolute path to the source font file.
#' @typed family: character(1)
#'   Family identifier used in the cache filename.
#' @typed variant: character(1)
#'   Symbolic variant key: one of `"regular"`, `"italic"`, `"bold"`,
#'   `"bolditalic"`.
#' @typed cache_dir: character | NULL
#'   Cache directory. Defaults to `get_cache_dir()` when `NULL`.
#' @typed quiet: logical(1)
#'   Suppress warnings/messages (default: FALSE).
#'
#' @typedreturn character | NULL
#'   Path to the cached file on success, or `NULL` on failure.
#'
copy_variant_to_cache <- function(
  src_path,
  family,
  variant,
  cache_dir = NULL,
  quiet = FALSE
) {
  assert_null_or_non_empty_string(src_path, allow_null = FALSE)
  assert_null_or_non_empty_string(family, allow_null = FALSE)

  valid_variants <- c("regular", "italic", "bold", "bolditalic")
  if (!variant %in% valid_variants) {
    cli::cli_abort(
      "{.arg variant} must be one of {.val {valid_variants}}, not {.val {variant}}."
    )
  }

  if (!fs::file_exists(src_path)) {
    if (!isTRUE(quiet)) {
      cli::cli_warn("Source file not found: {.file {src_path}}")
    }
    return(NULL)
  }

  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  dest <- cache_file_path(
    "file",
    family,
    variant,
    fs::path_ext(src_path),
    cache_dir
  )
  result <- tryCatch(
    fs::file_copy(src_path, dest, overwrite = TRUE),
    error = function(e) e
  )

  if (inherits(result, "error") || !fs::file_exists(dest)) {
    if (!isTRUE(quiet)) {
      cli::cli_warn(c(
        "!" = "Failed to copy {.val {family}} ({variant}) to cache.",
        "i" = if (inherits(result, "error")) {
          result$message
        } else {
          "No file written"
        }
      ))
    }
    return(NULL)
  }

  if (!isTRUE(quiet)) {
    cli::cli_alert_success("Copied variant: {.file {basename(dest)}}")
  }

  dest
}
