#' Read from list
#'
#' @typed l: list
#'   The list to convert to a CacheEntryList.
#'
#' @typedreturn CacheEntryList
#'   The CacheEntryList object created from the list.
#'
as_CacheEntryList <- S7::new_generic(
  "as_CacheEntryList",
  "l",
  function(l) {
    S7::S7_dispatch()
  }
)

#' @rdname as_CacheEntryList
#' @name as_CacheEntryList
#' @export
S7::method(as_CacheEntryList, S7::class_list) <- function(l) {
  el <- lapply(l, function(ent) {
    meta_raw <- ent$meta
    files <- meta_raw$files
    if (!is.list(files)) {
      files <- as.list(files)
    }

    # construct CacheMeta and CacheEntry (S7 constructors will validate)
    cm <- CacheMeta(
      family_id = meta_raw$family_id,
      source = meta_raw$source,
      files = files
    )
    ce <- CacheEntry(
      family = ent$family,
      meta = cm
    )
    return(ce)
  })
  cel <- CacheEntryList(entries = el)
  return(cel)
}
