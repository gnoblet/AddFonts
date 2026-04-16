# Session-scoped environment tracking which providers have shown their
# first-use message.  Initialised empty; entries are written by
# maybe_show_first_use() and can be cleared for testing.
.first_use_shown <- new.env(parent = emptyenv())

#' Show a provider's first-use message, at most once per session
#'
#' If `provider@first_use_message` is non-NULL and no message has been shown
#' for this provider's source in the current R session, emits the message via
#' `cli::cli_inform()` and records that it has been shown.  Subsequent calls
#' for the same provider are silently ignored.
#'
#' @typed provider: FontProvider
#'   The provider object whose message should (possibly) be displayed.
#'
#' @typedreturn invisible(NULL)
#'   Called for its side-effect only.
#'
maybe_show_first_use <- function(provider) {
  msg <- provider@first_use_message
  if (is.null(msg)) return(invisible(NULL))

  key <- provider@source
  if (isTRUE(.first_use_shown[[key]])) return(invisible(NULL))

  .first_use_shown[[key]] <- TRUE

  url <- provider@first_use_url
  if (!is.null(url)) {
    cli::cli_inform(c(msg, "i" = "See {.url {url}}"))
  } else {
    cli::cli_inform(msg)
  }

  invisible(NULL)
}
