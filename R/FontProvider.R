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
#' @export
FontProvider <- S7::new_class(
  "FontProvider",
  properties = list(
    source = S7::class_character,
    url_template = S7::class_character,
    conversion = S7::class_character | NULL,
    conversion_ext = S7::class_character | NULL,
    aliases = S7::class_list
  ),
  validator = function(self) {
    assert_null_or_non_empty_string(self@source, allow_null = FALSE)
    assert_null_or_non_empty_string(self@url_template, allow_null = FALSE)
    assert_null_or_non_empty_string(self@conversion)
    assert_null_or_non_empty_string(self@conversion_ext)

    if (
      !is.null(self@aliases) &&
        (!is.list(self@aliases) && !is.character(self@aliases))
    ) {
      cli::cli_abort(
        "{.arg aliases} must be NULL, a list, or a character vector."
      )
    }

    NULL
  }
)
