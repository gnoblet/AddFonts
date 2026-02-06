## Generic downloader + converter for provider_ls
#'
#' Download and (if needed) convert a provider artifact to a local TTF
#' file for a given family/weight/style and return the local path.
#'
#' @typed provider_l: list
#'   Provider details (must include `url_template` and `source`).
#' @typed family: character(1)
#'   Family identifier.
#' @typed weight: integer(1)
#'   Font weight to fetch.
#' @typed style: character(1)
#'   Style (e.g. "normal", "italic").
#' @typed subset: character(1)
#'   Glyph subset to request (default: "latin")
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL)
#' @typed quiet: logical(1)
#'   Suppress warnings/messages (default: FALSE)
#' @typedreturn character | NULL
#'   Path to the local `.ttf` file on success, or `NULL` on failure.
download_variant_generic <- function(
  provider_l,
  family,
  weight,
  style,
  subset = "latin",
  cache_dir = NULL,
  quiet = FALSE
) {
  #------ Arg check

  # weight is numeric between 100 and 900
  if (
    !is.numeric(weight) ||
      length(weight) != 1 ||
      !(weight %in% seq(100, 900, by = 100))
  ) {
    cli::cli_abort(
      "{.arg weight} must be a single integer between 100 and 900."
    )
  }

  #------ Do stuff

  # get cache dir path if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }
  # compute local cache paths (incl. conversion path if needed)
  paths <- cache_variant_paths(
    provider_l,
    family,
    weight,
    style,
    subset,
    cache_dir
  )

  # url fabrication---for now only support bunny
  url <- sprintf(
    provider_l$url_template,
    family,
    family,
    subset,
    as.integer(weight),
    style
  )

  # request + download
  req <- httr2::request(url) |> httr2::req_user_agent("AddFonts R package")
  path_for_req <- if (is.null(paths$to_convert)) paths$ttf else paths$to_convert
  resp <- tryCatch(
    httr2::req_perform(req, path = path_for_req),
    error = function(e) e
  )

  # if errored or no file written, warn and return NULL so callers can
  # decide whether to continue (e.g. fall back to normal when italic is
  # missing).
  if (inherits(resp, "error") || !fs::file_exists(path_for_req)) {
    if (!isTRUE(quiet)) {
      cli::cli_warn(c(
        "!" = "Download failed: {.val {if (inherits(resp, 'error')) resp$message else 'no file written'}}",
        "i" = "Please check that the font exists for this provider/variant.",
        "x" = "Tried download URL: {.url {url}}"
      ))
    }
    return(NULL)
  }

  ########################
  # Conversion if needed
  ########################
  # resolve conversion: provider_l$conversion may be NULL, a function, or a name
  # set default ttf_path (when no conversion is required the downloaded
  # artifact is the final ttf path)
  ttf_path <- paths$ttf

  if (!is.null(provider_l$conversion)) {
    conv_f <- conv_fun(provider_l$conversion)
    res <- tryCatch(
      conv_f(paths$to_convert, overwrite = TRUE, remove_old = TRUE),
      error = function(e) {
        e
      }
    )
    if (inherits(res, "error")) {
      if (!isTRUE(quiet)) {
        cli::cli_warn(c("Conversion failed:", "x" = res$message))
      }
      # attempt to remove the downloaded intermediate file even on failure
      if (!is.null(paths$to_convert) && fs::file_exists(paths$to_convert)) {
        try(fs::file_delete(paths$to_convert), silent = TRUE)
      }
      return(NULL)
    } else {
      ttf_path <- paths$ttf
    }
  }

  # remove downloaded intermediate files (e.g. .woff2) after successful
  # conversion or when final artifact was written directly
  # use deleted_files to track any deletion issues
  if (
    !is.null(paths$to_convert) &&
      fs::file_exists(paths$to_convert) &&
      paths$to_convert != ttf_path
  ) {
    delete_files(as.character(paths$to_convert), quiet = "none")
  }

  # Final check and return
  if (fs::file_exists(ttf_path)) {
    # if (!isTRUE(quiet)) {
    cli::cli_alert_success(
      "Downloaded variant: {.file {basename(ttf_path)}}"
    )
    # }
    return(ttf_path)
  } else {
    # if (!isTRUE(quiet)) {
    cli::cli_warn(
      "TTF file not found after download/conversion: {.file {ttf_path}}"
    )
    # }
    return(NULL)
  }
  NULL
}
