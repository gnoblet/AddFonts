#' Add a font to the local cache and register it for use
#'
#' Ensure a font is available locally: try the cache first, otherwise
#' download/convert and register the font so it can be used by plotting
#' devices. Returns (invisibly) the list of local file paths.
#'
#' For weight-based providers (e.g. Bunny Fonts), supply `regular.wt`,
#' `bold.wt`, and `subset`. For file-based providers (e.g. Bye Bye Binary),
#' supply `variants` instead.
#'
#' @typed name: character(1)
#'   Name of the font as known to the provider.
#' @typed provider: character(1) | FontProvider
#'   Provider id/name (default: `"bunny"`), or a `FontProvider` object
#'   constructed with [FontProviderWeight()] or [FontProviderFile()]
#'   (bypasses the registry lookup).
#' @typed family: character | NULL
#'   Optional family name to register the font under (default: NULL).
#' @typed variants: list | NULL
#'   For file-based providers only. Named list mapping symbolic variant keys
#'   (`"regular"`, `"italic"`, `"bold"`, `"bolditalic"`) to filename stems
#'   served by the provider (without extension). Must include at least
#'   `"regular"`. Ignored for weight-based providers (default: NULL).
#' @typed regular.wt: numeric(1)
#'   For weight-based providers. Regular weight to request (default: 400).
#' @typed bold.wt: numeric(1)
#'   For weight-based providers. Bold weight to request (default: 700).
#' @typed subset: character(1)
#'   For weight-based providers. Glyph subset to request (default: "latin").
#'
#' @typedreturn list
#'   Invisibly returns a list with paths for `regular`, `italic`, `bold` and
#'   `bolditalic` variants, or throws an error on failure.
#'
#' @export
add_font <- function(
  name,
  provider = "bunny",
  family = NULL,
  variants = NULL,
  regular.wt = 400,
  bold.wt = 700,
  subset = "latin"
) {
  #------ Arg check
  assert_null_or_non_empty_string(name, allow_null = FALSE)
  if (!S7::S7_inherits(provider, FontProvider)) {
    assert_null_or_non_empty_string(provider, allow_null = FALSE)
  }
  assert_null_or_non_empty_string(family, allow_null = TRUE)

  #------ Prepare identifiers and provider
  provider_obj <- if (S7::S7_inherits(provider, FontProvider)) {
    provider
  } else if (is.character(provider) && provider %in% c("file", "url")) {
    provider   # pass through as string; routing handled below
  } else {
    get_provider_details(provider)
  }
  family_name <- if (is.null(family)) name else family
  cache_dir <- get_cache_dir()

  if (S7::S7_inherits(provider_obj, FontProvider)) {
    maybe_show_first_use(provider_obj)
  }

  #------ Route by provider type
  if (identical(provider_obj, "file")) {
    return(.add_font_local(name, family_name, variants, cache_dir))
  }
  if (identical(provider_obj, "url")) {
    return(.add_font_direct_url(name, family_name, variants, cache_dir))
  }
  if (S7::S7_inherits(provider_obj, FontProviderFile)) {
    .add_font_file(
      provider_obj = provider_obj,
      name         = name,
      family_name  = family_name,
      variants     = variants,
      cache_dir    = cache_dir
    )
  } else {
    .add_font_weight(
      provider_obj = provider_obj,
      name         = name,
      family_name  = family_name,
      regular.wt   = regular.wt,
      bold.wt      = bold.wt,
      subset       = subset,
      cache_dir    = cache_dir
    )
  }
}

