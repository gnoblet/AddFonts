# Session-level provider registry
# Cleared on R session restart; complements the built-in sysdata providers.
.provider_registry <- new.env(parent = emptyenv())

# ---- register_provider -------------------------------------------------------

#' Register a font provider for the current session
#'
#' Adds a `FontProvider` object to the session-level registry so it can be
#' referenced by name in [add_font()]. The registry is cleared when the R
#' session ends.
#'
#' @typed provider: FontProvider
#'   A validated `FontProvider` object to register.
#' @typed overwrite: logical(1)
#'   If `TRUE`, silently overwrite an existing provider with the same source
#'   name. If `FALSE` (default), error instead.
#'
#' @typedreturn NULL
#'   Called for its side-effect; returns `NULL` invisibly.
#'
#' @export
register_provider <- S7::new_generic(
  "register_provider",
  "provider",
  function(provider, overwrite = FALSE) S7::S7_dispatch()
)

S7::method(register_provider, FontProvider) <- function(provider, overwrite = FALSE) {
  if (!is.logical(overwrite) || length(overwrite) != 1) {
    cli::cli_abort("{.arg overwrite} must be a logical scalar.")
  }

  name <- provider@source

  if (exists(name, envir = .provider_registry, inherits = FALSE) && !overwrite) {
    cli::cli_abort(c(
      "A provider with source {.val {name}} is already registered.",
      "i" = "Use {.code overwrite = TRUE} to replace it."
    ))
  }

  assign(name, provider, envir = .provider_registry)
  cli::cli_alert_success("Provider {.val {name}} registered for this session.")
  invisible(NULL)
}

# ---- unregister_provider -----------------------------------------------------

#' Remove a font provider from the session registry
#'
#' Dispatches on a source name (`character`) or a `FontProvider` object.
#'
#' @typed x: character(1) | FontProvider
#'   Source name of the provider to remove, or the `FontProvider` object itself.
#'
#' @typedreturn NULL
#'   Called for its side-effect; returns `NULL` invisibly.
#'
#' @export
unregister_provider <- S7::new_generic(
  "unregister_provider",
  "x",
  function(x) S7::S7_dispatch()
)

S7::method(unregister_provider, S7::class_character) <- function(x) {
  assert_null_or_non_empty_string(x, allow_null = FALSE)

  if (!exists(x, envir = .provider_registry, inherits = FALSE)) {
    cli::cli_abort("No user-registered provider found with source {.val {x}}.")
  }

  rm(list = x, envir = .provider_registry)
  cli::cli_alert_success("Provider {.val {x}} removed from the session registry.")
  invisible(NULL)
}

S7::method(unregister_provider, FontProvider) <- function(x) {
  unregister_provider(x@source)
}

# ---- list_providers ----------------------------------------------------------

#' List all available font providers
#'
#' Returns a named list of all `FontProvider` objects: built-in providers
#' first, then any providers registered in the current session. Session
#' providers with the same source name as a built-in take precedence.
#'
#' @typedreturn list
#'   Named list of `FontProvider` objects keyed by their source name.
#'
#' @export
list_providers <- function() {
  builtin <- if (exists("providers", mode = "list", envir = asNamespace("AddFonts"))) {
    providers_data <- get("providers", envir = asNamespace("AddFonts"))
    lapply(providers_data, as_FontProvider)
  } else {
    list()
  }

  session <- as.list(.provider_registry)

  # Session providers shadow built-ins with the same source name
  merged <- c(builtin, session)
  merged[!duplicated(names(merged), fromLast = TRUE)]
}
