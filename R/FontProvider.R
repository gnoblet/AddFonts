#' Base font provider class (FontProvider)
#'
#' Abstract base class shared by all provider types. Do not construct this directly — use [FontProviderWeight()] or [FontProviderFile()] instead.
#'
#' @typed source: character(1)
#'   Provider id/name (e.g. `"bunny"`, `"bbb"`).
#'
#' @typed aliases: list
#'   Optional list of alias strings to recognise the provider by
#'   (e.g. `list("fonts.bunny.net")`).
#'
#' @typed first_use_message: character(1) | NULL
#'   Optional message displayed once per R session the first time this provider is used (e.g. a licensing notice). `NULL` means no message.
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
    source = S7::class_character,
    aliases = S7::class_list,
    first_use_message = S7::class_character | NULL,
    first_use_url = S7::class_character | NULL
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
