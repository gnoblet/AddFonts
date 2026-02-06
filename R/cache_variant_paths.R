# Helper — compute canonical cache paths for a provider/family/variant
#'
#' Compute paths used for caching provider artifacts and any conversion
#' intermediate files.
#'
#' @typed provider_l: list
#'   Provider details list (must include `source` and optional conversion info).
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
  provider_l,
  family,
  weight,
  style,
  subset,
  cache_dir = NULL
) {
  #------ Arg check

  # all args are checked in cache_ttf_path()
  # but provider_l

  # provider_l is a liset with at least a source item
  assert_list_with_elements(
    provider_l,
    required_elements = c("source", "conversion", "conversion_ext")
  )

  # source  is not null and is a non-empty string
  assert_null_or_non_empty_string(provider_l$source, allow_null = FALSE)

  # conversion is NULL or a non-empty string
  assert_null_or_non_empty_string(provider_l$conversion, allow_null = TRUE)

  # conversion_ext is NULL or a non-empty string
  assert_null_or_non_empty_string(provider_l$conversion_ext, allow_null = TRUE)

  #------ Do stuff

  # get cache dir path if NULL
  ttf_path <- cache_ttf_path(
    provider_l$source,
    family,
    subset,
    weight,
    style,
    cache_dir
  )
  # allow provider_l to specify the source extension to convert from
  if (!is.null(provider_l$conversion) && !is.null(provider_l$conversion_ext)) {
    ext <- provider_l$conversion_ext
    to_convert_path <- fs::path_ext_set(ttf_path, ext)
  } else {
    to_convert_path <- NULL
  }

  return(list(to_convert = to_convert_path, ttf = ttf_path))
}
