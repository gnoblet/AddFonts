#' File-based font provider (FontProviderFile)
#'
#' Provider that downloads font files directly by filename from a base URL,
#' with no weight/style/subset parameterisation. Covers Git-hosted
#' collections like Bye Bye Binary where each variant has a fixed filename.
#'
#' @typed source: character(1)
#'   Provider id/name (e.g. `"bbb"`).
#'
#' @typed base_url: character(1)
#'   Glue-style URL template. Must contain `{family}` and `{filename}`
#'   placeholders (e.g.
#'   `"https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf"`).
#'
#' @typed file_ext: character(1)
#'   Extension of the font files served by this provider (default: `"ttf"`).
#'   Must be `"ttf"` or `"otf"` (no conversion is performed).
#'
#' @typed aliases: list
#'   Optional alias strings (inherited from [FontProvider()]).
#'
#' @typed first_use_message: character(1) | NULL
#'   Inherited from [FontProvider()].
#'
#' @typed first_use_url: character(1) | NULL
#'   Inherited from [FontProvider()].
#'
#' @typedreturn FontProviderFile
#'   A validated S7 `FontProviderFile` object.
#'
#' @export
FontProviderFile <- S7::new_class(
  "FontProviderFile",
  parent = FontProvider,
  properties = list(
    base_url = S7::class_character,
    file_ext = S7::class_character
  ),
  constructor = function(
    source,
    base_url,
    file_ext           = "ttf",
    aliases            = list(),
    first_use_message  = NULL,
    first_use_url      = NULL
  ) {
    S7::new_object(
      S7::S7_object(),
      source            = source,
      base_url          = base_url,
      file_ext          = file_ext,
      aliases           = aliases,
      first_use_message = first_use_message,
      first_use_url     = first_use_url
    )
  },
  validator = function(self) {
    assert_null_or_non_empty_string(self@source, allow_null = FALSE)
    assert_null_or_non_empty_string(self@first_use_message)
    assert_null_or_non_empty_string(self@first_use_url)

    assert_null_or_non_empty_string(self@base_url, allow_null = FALSE)
    assert_null_or_non_empty_string(self@file_ext, allow_null = FALSE)

    if (!grepl("{family}", self@base_url, fixed = TRUE)) {
      return("@base_url must contain the {family} placeholder.")
    }
    if (!grepl("{filename}", self@base_url, fixed = TRUE)) {
      return("@base_url must contain the {filename} placeholder.")
    }

    NULL
  }
)
