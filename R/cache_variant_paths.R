#' Compute paths used for caching provider artifacts and any conversion intermediate files.
#'
#' @typed provider: FontProvider
#'   Provider object with source and optional conversion info.
#' @typed family: character(1)
#'   Family identifier.
#' @typed weight: integer(1)
#'   Font weight.
#' @typed style: character(1)
#'   Style string (e.g. "normal", "italic").
#' @typed subset: character(1)
#'   Glyph subset identifier.
#' @typed cache_dir: character | NULL
#'   Cache directory to use (default: NULL)
#'
#' @typedreturn list
#'   A list with elements `to_convert` (path or NULL) and `ttf` (path).
#'
cache_variant_paths <- function(
  provider,
  family,
  weight,
  style,
  subset,
  cache_dir = NULL
) {
  #------ Arg check

  # Ensure provider is a FontProvider object
  if (!S7::S7_inherits(provider, FontProvider)) {
    cli::cli_abort("{.arg provider} must be a <FontProvider> object.")
  }

  #------ Do stuff

  # Compute TTF path
  ttf_path <- cache_ttf_path(
    provider@source,
    family,
    subset,
    weight,
    style,
    cache_dir
  )

  # Determine conversion path if needed
  if (!is.null(provider@conversion) && !is.null(provider@conversion_ext)) {
    to_convert_path <- fs::path_ext_set(ttf_path, provider@conversion_ext)
  } else {
    to_convert_path <- NULL
  }

  return(list(to_convert = to_convert_path, ttf = ttf_path))
}
