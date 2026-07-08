#' Base font provider class (FontProvider)
#'
#' Abstract base class shared by all provider types. Do not construct this directly. Use `FontProviderWeight()` or `FontProviderFile()` instead.
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
FontProvider <- S7::new_class(
  "FontProvider",
  properties = list(
    source = S7::class_character,
    aliases = S7::class_list,
    first_use_message = S7::class_character | NULL,
    first_use_url = S7::class_character | NULL
  ),
  validator = function(self) {
    if (identical(S7::S7_class(self)@name, "FontProvider")) {
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

#' Sentinel provider for local font files (provider = "file")
#'
#' Returned internally when `add_font(provider = "file")` is used. Carries no extra properties — its type alone signals the local-copy dispatch path.
#'
FontProviderLocal <- S7::new_class(
  "FontProviderLocal",
  parent = FontProvider,
  constructor = function() {
    S7::new_object(
      S7::S7_object(),
      source = "file",
      aliases = list(),
      first_use_message = NULL,
      first_use_url = NULL
    )
  }
)

#' Sentinel provider for direct-URL font downloads (provider = "url")
#'
#' Returned internally when `add_font(provider = "url")` is used. Carries no extra properties — its type alone signals the direct-URL dispatch path.
#'
FontProviderDirectURL <- S7::new_class(
  "FontProviderDirectURL",
  parent = FontProvider,
  constructor = function() {
    S7::new_object(
      S7::S7_object(),
      source = "url",
      aliases = list(),
      first_use_message = NULL,
      first_use_url = NULL
    )
  }
)
