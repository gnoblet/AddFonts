#' Download one font file from a file-based provider
#'
#' Downloads a single font variant directly from a [FontProviderFile()] using
#' its `base_url` template. No conversion is performed — the file is stored as
#' received.
#'
#' @typed provider: FontProviderFile
#'   A file-based provider object.
#' @typed family: character(1)
#'   Family identifier used in the URL template and cache filename.
#' @typed filename: character(1)
#'   Filename stem (without extension) for the specific variant (e.g.
#'   `"Alpaga-Regular"`). Substituted into the `{filename}` placeholder of
#'   `provider@base_url`.
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
  assert_null_or_non_empty_string(family,   allow_null = FALSE)
  assert_null_or_non_empty_string(filename, allow_null = FALSE)
  assert_null_or_non_empty_string(variant,  allow_null = FALSE)

  valid_variants <- c("regular", "italic", "bold", "bolditalic")
  if (!variant %in% valid_variants) {
    cli::cli_abort(
      "{.arg variant} must be one of {.val {valid_variants}}, not {.val {variant}}."
    )
  }

  if (is.null(cache_dir)) cache_dir <- get_cache_dir()

  #------ Compute local cache path
  local_path <- cache_file_path(
    source    = provider@source,
    family    = family,
    variant   = variant,
    file_ext  = provider@file_ext,
    cache_dir = cache_dir
  )

  #------ Build URL
  url <- glue::glue_data(
    list(family = family, filename = filename),
    provider@base_url
  )

  #------ Download
  req  <- httr2::request(url) |> httr2::req_user_agent("AddFonts R package")
  resp <- tryCatch(
    httr2::req_perform(req, path = local_path),
    error = function(e) e
  )

  if (inherits(resp, "error") || !fs::file_exists(local_path)) {
    if (!isTRUE(quiet)) {
      cli::cli_warn(c(
        "!" = "Download failed for {.val {family}} ({variant})",
        "i" = if (inherits(resp, "error")) resp$message else "No file written",
        "x" = "URL: {.url {url}}"
      ))
    }
    return(NULL)
  }

  if (!isTRUE(quiet)) {
    cli::cli_alert_success("Downloaded variant: {.file {basename(local_path)}}")
  }

  local_path
}
