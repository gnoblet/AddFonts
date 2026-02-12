#' Download and (if needed) convert a provider artifact to a local TTF  file for a given family/weight/style and return the local path.
#'
#' @typed provider: FontProvider
#'   Provider object with url_template and source.
#' @typed family: character(1)
#'   Family identifier.
#' @typed weight: integer(1)
#'   Font weight to fetch (100-900).
#' @typed style: character(1)
#'   Style (e.g. "normal", "italic").
#' @typed subset: character(1)
#'   Glyph subset to request (default: "latin")
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL)
#' @typed quiet: logical(1)
#'   Suppress warnings/messages (default: FALSE)
#'
#' @typedreturn character | NULL
#'   Path to the local `.ttf` file on success, or `NULL` on failure.
#'
download_variant_generic <- function(
  provider,
  family,
  weight,
  style,
  subset = "latin",
  cache_dir = NULL,
  quiet = FALSE
) {
  #------ Arg check
  if (!S7::S7_inherits(provider, FontProvider)) {
    cli::cli_abort("{.arg provider} must be a <FontProvider> object.")
  }

  if (
    !is.numeric(weight) ||
      length(weight) != 1 ||
      !(weight %in% seq(100, 900, by = 100))
  ) {
    cli::cli_abort(
      "{.arg weight} must be a single integer between 100 and 900."
    )
  }

  # Get cache dir if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  #------ Compute cache paths
  paths <- cache_variant_paths(
    provider,
    family,
    weight,
    style,
    subset,
    cache_dir
  )

  #------ Build URL and download
  url <- sprintf(
    provider@url_template,
    family,
    family,
    subset,
    as.integer(weight),
    style
  )

  # Determine download target
  download_path <- if (is.null(paths$to_convert)) {
    paths$ttf
  } else {
    paths$to_convert
  }

  # Execute request
  req <- httr2::request(url) |> httr2::req_user_agent("AddFonts R package")
  resp <- tryCatch(
    httr2::req_perform(req, path = download_path),
    error = function(e) e
  )

  # Handle download failure
  if (inherits(resp, "error") || !fs::file_exists(download_path)) {
    if (!isTRUE(quiet)) {
      cli::cli_warn(c(
        "!" = "Download failed for {.val {family}} ({weight}/{style})",
        "i" = if (inherits(resp, "error")) resp$message else "No file written",
        "x" = "URL: {.url {url}}"
      ))
    }
    return(NULL)
  }

  #------ Conversion (if needed)
  if (!is.null(provider@conversion)) {
    conv_f <- conv_fun(provider@conversion)
    res <- tryCatch(
      conv_f(paths$to_convert, overwrite = TRUE, remove_old = TRUE),
      error = function(e) e
    )

    if (inherits(res, "error")) {
      if (!isTRUE(quiet)) {
        cli::cli_warn(c("Conversion failed:", "x" = res$message))
      }
      # Clean up downloaded file on conversion failure
      if (!is.null(paths$to_convert) && fs::file_exists(paths$to_convert)) {
        try(fs::file_delete(paths$to_convert), silent = TRUE)
      }
      return(NULL)
    }
  }

  #------ Final check and return
  if (!fs::file_exists(paths$ttf)) {
    if (!isTRUE(quiet)) {
      cli::cli_warn(
        "TTF file not found after download/conversion: {.file {paths$ttf}}"
      )
    }
    return(NULL)
  }

  cli::cli_alert_success(
    "Downloaded variant: {.file {basename(paths$ttf)}}"
  )

  return(paths$ttf)
}
