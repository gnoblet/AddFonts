#' Compute canonical cache path for a TTF file
#'
#' @typed source: character(1)
#'   Provider source identifier.
#' @typed font_id: character(1)
#'   Font id used for filenames.
#' @typed subset: character(1)
#'   Glyph subset identifier.
#' @typed weight: integer(1)
#'   Font weight.
#' @typed style: character(1)
#'   Style string (e.g. "normal", "italic").
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL)
#'
#' @typedreturn character(1)
#'   Path to the cached `.ttf` file.
#'
cache_ttf_path <- function(
  source,
  font_id,
  subset,
  weight,
  style,
  cache_dir = NULL
) {
  #------ Arg check
  assert_null_or_non_empty_string(source, allow_null = FALSE)
  assert_null_or_non_empty_string(font_id, allow_null = FALSE)
  assert_null_or_non_empty_string(subset, allow_null = FALSE)
  assert_null_or_non_empty_string(style, allow_null = FALSE)
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

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

  # compose full path
  fs::path(
    cache_dir,
    cache_ttf_filename(source, font_id, subset, weight, style)
  )
}

#' Compose canonical filename for a cached TTF
#'
#' @typed source: character(1)
#'   Provider source identifier.
#' @typed font_id: character(1)
#'   Font id used to create a filesystem-safe filename.
#' @typed subset: character(1)
#'   Glyph subset identifier.
#' @typed weight: integer(1)
#'   Font weight.
#' @typed style: character(1)
#'   Style string (e.g. "normal", "italic").
#'
#' @typedreturn character(1)
#'   Filename (not including the cache directory) for the cached TTF.
#'
cache_ttf_filename <- function(source, font_id, subset, weight, style) {
  # ----- Arg check
  assert_null_or_non_empty_string(source, allow_null = FALSE)
  assert_null_or_non_empty_string(font_id, allow_null = FALSE)
  assert_null_or_non_empty_string(subset, allow_null = FALSE)
  assert_null_or_non_empty_string(style, allow_null = FALSE)

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

  # ----- Do stuff

  # make font_id safe
  sid <- safe_id(font_id)

  # compose filename
  sprintf(
    "%s-%s-%s-%d-%s.ttf",
    source,
    sid,
    subset,
    as.integer(weight),
    style
  )
}
