#' Font provider specification (FontProvider)
#'
#' @typed source: character(1)
#'   Provider id/name (e.g. "bunny").
#'
#' @typed url_template: character(1)
#'   URL template used to construct download URLs.
#'
#' @typed conversion: character(1) | NULL
#'   Optional conversion function name (as string) or `NULL`.
#'
#' @typed conversion_ext: character(1) | NULL
#'   Original extension handled by the provider (e.g. "woff2").
#'
#' @typed aliases: list | NULL
#'   Optional list of alias names to match (e.g. "fonts.bunny.net").
#'
#' @typedreturn FontProviders
#'  S7 class representing a font provider specification.
#'
FontProvider <- S7::new_class(
  "FontProvider",
  properties = list(
    source = S7::class_character,
    url_template = S7::class_character,
    conversion = S7::class_any,
    conversion_ext = S7::class_any,
    aliases = S7::class_list
  ),
  validator = function(self) {
    assert_null_or_non_empty_string(self@source, allow_null = FALSE)
    assert_null_or_non_empty_string(self@url_template, allow_null = FALSE)
    assert_null_or_non_empty_string(self@conversion)
    assert_null_or_non_empty_string(self@conversion_ext)

    if (
      !is.null(self@conversion) &&
        (!is.character(self@conversion) || length(self@conversion) != 1)
    ) {
      cli::cli_abort(
        "`conversion` must be NULL or a character(1) function name."
      )
    }
    if (
      !is.null(self@conversion_ext) &&
        (!is.character(self@conversion_ext) || length(self@conversion_ext) != 1)
    ) {
      cli::cli_abort(
        "`conversion_ext` must be NULL or a character(1) file extension."
      )
    }

    if (
      !is.null(self@aliases) &&
        (!is.list(self@aliases) && !is.character(self@aliases))
    ) {
      cli::cli_abort(
        "`aliases` must be NULL, a list or character vector of aliases."
      )
    }

    NULL
  }
)
