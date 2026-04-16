#' Base font provider class (FontProvider)
#'
#' Abstract base class shared by all provider types. Do not construct this
#' directly — use [FontProviderWeight()] or [FontProviderFile()] instead.
#'
#' @typed source: character(1)
#'   Provider id/name (e.g. `"bunny"`, `"bbb"`).
#'
#' @typed aliases: list
#'   Optional list of alias strings to recognise the provider by
#'   (e.g. `list("fonts.bunny.net")`).
#'
#' @typed first_use_message: character(1) | NULL
#'   Optional message displayed once per R session the first time this
#'   provider is used (e.g. a licensing notice). `NULL` means no message.
#'
#' @typed first_use_url: character(1) | NULL
#'   Optional URL shown alongside `first_use_message`. `NULL` means no URL.
#'
#' @typedreturn FontProvider
#'   S7 base class. Use a subclass constructor in practice.
#'
#' @export
FontProvider <- S7::new_class(
  "FontProvider",
  properties = list(
    source            = S7::class_character,
    aliases           = S7::class_list,
    first_use_message = S7::class_character | NULL,
    first_use_url     = S7::class_character | NULL
  ),
  validator = function(self) {
    # Prevent direct construction of the base class
    if (
      !S7::S7_inherits(self, FontProviderWeight) &&
        !S7::S7_inherits(self, FontProviderFile)
    ) {
      cli::cli_abort(c(
        "Cannot construct {.cls FontProvider} directly.",
        "i" = "Use {.fn FontProviderWeight} or {.fn FontProviderFile} instead."
      ))
    }

    assert_null_or_non_empty_string(self@source, allow_null = FALSE)
    assert_null_or_non_empty_string(self@first_use_message)
    assert_null_or_non_empty_string(self@first_use_url)

    NULL
  }
)

#' Weight-based font provider (FontProviderWeight)
#'
#' Provider that resolves font variants by numeric weight and style via a
#' glue-style URL template. This covers APIs like Bunny Fonts.
#'
#' @typed source: character(1)
#'   Provider id/name (e.g. `"bunny"`).
#'
#' @typed url_template: character(1)
#'   Glue-style URL template. Must contain `{family}`. Typically also uses
#'   `{subset}`, `{weight}` (integer), and `{style}`.
#'
#' @typed conversion: character(1) | NULL
#'   Name of a conversion function to apply after download (e.g.
#'   `"woff2_to_ttf"`), or `NULL` if the provider serves TTF directly.
#'
#' @typed conversion_ext: character(1) | NULL
#'   File extension of the downloaded artifact before conversion
#'   (e.g. `"woff2"`), or `NULL`.
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
#' @typedreturn FontProviderWeight
#'   A validated S7 `FontProviderWeight` object.
#'
#' @export
FontProviderWeight <- S7::new_class(
  "FontProviderWeight",
  parent = FontProvider,
  properties = list(
    url_template   = S7::class_character,
    conversion     = S7::class_character | NULL,
    conversion_ext = S7::class_character | NULL
  ),
  constructor = function(
    source,
    url_template,
    conversion        = NULL,
    conversion_ext    = NULL,
    aliases           = list(),
    first_use_message = NULL,
    first_use_url     = NULL
  ) {
    S7::new_object(
      S7::S7_object(),
      source            = source,
      url_template      = url_template,
      conversion        = conversion,
      conversion_ext    = conversion_ext,
      aliases           = aliases,
      first_use_message = first_use_message,
      first_use_url     = first_use_url
    )
  },
  validator = function(self) {
    assert_null_or_non_empty_string(self@source, allow_null = FALSE)
    assert_null_or_non_empty_string(self@first_use_message)
    assert_null_or_non_empty_string(self@first_use_url)

    assert_null_or_non_empty_string(self@url_template, allow_null = FALSE)
    assert_null_or_non_empty_string(self@conversion)
    assert_null_or_non_empty_string(self@conversion_ext)

    if (!grepl("{family}", self@url_template, fixed = TRUE)) {
      return("@url_template must contain the {family} placeholder.")
    }

    NULL
  }
)
