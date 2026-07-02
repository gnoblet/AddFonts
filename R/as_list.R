#' As list
#'
#' @typed x: CacheMeta | CacheEntry | CacheEntryList
#'   The object to convert to a list.
#'
#' @typedreturn list
#'   The list representation of the CacheEntryList.
#'
as_list <- S7::new_generic(
  "as_list",
  "x",
  function(x) {
    S7::S7_dispatch()
  }
)

#' @rdname as_list
#' @name as_list
#' @export
S7::method(as_list, CacheMeta) <- function(x) {
  list(
    source = x@source,
    key_scheme = x@key_scheme,
    files = x@files,
    failed_keys = as.list(x@failed_keys)
  )
}

#' @rdname as_list
#' @name as_list
#' @export
S7::method(as_list, CacheEntry) <- function(x) {
  list(
    family = x@family,
    meta = as_list(x@meta)
  )
}

#' @rdname as_list
#' @name as_list
#' @export
S7::method(as_list, CacheEntryList) <- function(x) {
  unname(lapply(x@entries, as_list))
}
