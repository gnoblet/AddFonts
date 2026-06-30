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
      source = meta_raw$source,
      files = files
    )
    CacheEntry(
      family = ent$family,
      meta = cm
    )
  })

  # Name with compound source::family keys.
  # Works for both new format and legacy single-key JSON (migration is free
  # since source is always stored inside meta).
  names(el) <- vapply(
    el,
    function(e) paste0(e@meta@source, "::", e@family),
    character(1)
  )

  CacheEntryList(entries = el)
}
