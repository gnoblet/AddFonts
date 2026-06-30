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

#' Compute canonical cache path for a file-based (symbolic-variant) font file
#'
#' Used by file-based providers (e.g. Bye Bye Binary) where each variant is
#' identified by a symbolic key (`"regular"`, `"italic"`, `"bold"`,
#' `"bolditalic"`) rather than a numeric weight.
#'
#' @typed source: character(1)
#'   Provider source identifier.
#' @typed family: character(1)
#'   Family name (will be made filesystem-safe via `safe_id()`).
#' @typed variant: character(1)
#'   Symbolic variant key: one of `"regular"`, `"italic"`, `"bold"`,
#'   `"bolditalic"`.
#' @typed file_ext: character(1)
#'   File extension of the cached font (e.g. `"ttf"`, `"otf"`).
#' @typed cache_dir: character | NULL
#'   Cache directory. Defaults to `get_cache_dir()` when `NULL`.
#'
#' @typedreturn character(1)
#'   Full path to the locally cached font file.
#'
cache_file_path <- function(
  source,
  family,
  variant,
  file_ext,
  cache_dir = NULL
) {
  assert_null_or_non_empty_string(source, allow_null = FALSE)
  assert_null_or_non_empty_string(family, allow_null = FALSE)
  assert_null_or_non_empty_string(variant, allow_null = FALSE)
  assert_null_or_non_empty_string(file_ext, allow_null = FALSE)
  assert_null_or_non_empty_string(cache_dir, allow_null = TRUE)

  if (is.null(cache_dir)) {
    cache_dir <- get_cache_dir()
  }

  sid <- safe_id(family)
  fname <- sprintf("%s-%s-%s.%s", source, sid, variant, file_ext)
  fs::path(cache_dir, fname)
}
