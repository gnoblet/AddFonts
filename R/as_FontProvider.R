#' Construct a FontProvider subclass from a named list
#'
#' Reads the `type` field (`"weight"` or `"file"`) and constructs the
#' appropriate subclass. Missing `type` defaults to `"weight"` for backward
#' compatibility with existing `providers.json` entries.
#'
#' @typed x: list
#'  Named list (e.g. from JSON) with provider details.
#'
#' @typedreturn FontProviderWeight | FontProviderFile
#'  The corresponding provider object.
#'
as_FontProvider <- S7::new_generic(
  "as_FontProvider",
  "x",
  function(x) {
    S7::S7_dispatch()
  }
)

#' @rdname as_FontProvider
#' @name as_FontProvider
#' @export
S7::method(as_FontProvider, S7::class_list) <- function(x) {
  type    <- if (is.null(x$type)) "weight" else x$type
  aliases <- if (is.null(x$aliases)) list() else x$aliases

  if (type == "weight") {
    FontProviderWeight(
      source            = x$source,
      url_template      = x$url_template,
      conversion        = x$conversion,
      conversion_ext    = x$conversion_ext,
      aliases           = aliases,
      first_use_message = x$first_use_message,
      first_use_url     = x$first_use_url
    )
  } else if (type == "file") {
    FontProviderFile(
      source            = x$source,
      base_url          = x$base_url,
      file_ext          = if (is.null(x$file_ext)) "ttf" else x$file_ext,
      aliases           = aliases,
      first_use_message = x$first_use_message,
      first_use_url     = x$first_use_url
    )
  } else {
    cli::cli_abort(c(
      "Unknown provider {.field type}: {.val {type}}.",
      "i" = "Supported types: {.val weight}, {.val file}."
    ))
  }
}
