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

  # source is a non-empty character string
  if (!is.character(source) || length(source) != 1 || !nzchar(source)) {
    cli::cli_abort("{.arg source} must be a non-empty string.")
  }

  # font_id is a non-empty character string
  if (!is.character(font_id) || length(font_id) != 1 || !nzchar(font_id)) {
    cli::cli_abort("{.arg font_id} must be a non-empty string.")
  }

  # subset is a non-empty character string
  if (!is.character(subset) || length(subset) != 1 || !nzchar(subset)) {
    cli::cli_abort("{.arg subset} must be a non-empty string.")
  }

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

  # style is a non-empty character string
  if (!is.character(style) || length(style) != 1 || !nzchar(style)) {
    cli::cli_abort("{.arg style} must be a non-empty string.")
  }

  # cache_dir is NULL or a path
  if (
    !is.null(cache_dir) &&
      (!is.character(cache_dir) || length(cache_dir) != 1 || !nzchar(cache_dir))
  ) {
    cli::cli_abort("{.arg cache_dir} must be a non-empty string or NULL.")
  }

  #------ Do stuff

  # get cache dir path if NULL
  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  # compose full path
  fp <- fs::path(
    cache_dir,
    cache_ttf_filename(source, font_id, subset, weight, style)
  )

  return(fp)
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

  # source is a non-empty character string
  if (!is.character(source) || length(source) != 1 || !nzchar(source)) {
    cli::cli_abort("{.arg source} must be a non-empty string.")
  }
  # font_id is a non-empty character string
  if (!is.character(font_id) || length(font_id) != 1 || !nzchar(font_id)) {
    cli::cli_abort("{.arg font_id} must be a non-empty string.")
  }
  # subset is a non-empty character string
  if (!is.character(subset) || length(subset) != 1 || !nzchar(subset)) {
    cli::cli_abort("{.arg subset} must be a non-empty string.")
  }
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
  # style is a non-empty character string
  if (!is.character(style) || length(style) != 1 || !nzchar(style)) {
    cli::cli_abort("{.arg style} must be a non-empty string.")
  }

  # ----- Do stuff

  # make font_id safe
  sid <- safe_id(font_id)

  # compose filename
  fn <- sprintf(
    "%s-%s-%s-%d-%s.ttf",
    source,
    sid,
    subset,
    as.integer(weight),
    style
  )

  return(fn)
}
