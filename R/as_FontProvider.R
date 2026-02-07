#' Construct a `FontProvider` from a named list
#'
#' @typed x: list
#'  Named list (e.g. from JSON) with provider details.
#'
#' @typedreturn FontProvider
#'  The corresponding `FontProvider` object.
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
  fp <- FontProvider(
    source = x$source,
    url_template = x$url_template,
    conversion = x$conversion,
    conversion_ext = x$conversion_ext,
    aliases = x$aliases
  )
  return(fp)
}
