#' S7 list of cache entries (CacheEntryList)
#'
#' @typed entries: list(1+)
#'  A non-empty list of `CacheEntry` objects.
#'
#' @typedreturn S7_object
#'  A validated S7 `CacheEntryList` object.
#'
#' @export
CacheEntryList <- S7::new_class(
  "CacheEntryList",
  properties = list(
    entries = S7::class_list
  ),
  constructor = function(entries = list()) {
    # Auto-name each CacheEntry with its compound "source::family" key,
    # overriding any caller-supplied names to keep the index consistent.
    if (length(entries) > 0) {
      nms <- character(length(entries))
      for (i in seq_along(entries)) {
        e <- entries[[i]]
        if (S7::S7_inherits(e, CacheEntry)) {
          nms[i] <- tryCatch(
            paste0(e@meta@source, "::", e@family),
            error = function(err) ""
          )
        }
      }
      names(entries) <- nms
    }
    S7::new_object(S7::S7_object(), entries = entries)
  },
  validator = function(self) {
    entries <- self@entries
    # entries is either an empty list or a list of CacheEntry objects

    if (length(entries) == 0) {
      return(NULL)
    }

    # check if all entries are CacheEntry objects
    res <- vapply(entries, function(e) S7::S7_inherits(e, CacheEntry), logical(1))
    if (!all(res)) {
      cli::cli_abort(
        "All elements of self@entries must be <CacheEntry> objects."
      )
    }

    # check uniqueness by compound source::family key (allows same family
    # name across different providers)
    keys <- vapply(
      entries,
      function(e) paste0(e@meta@source, "::", e@family),
      character(1)
    )
    if (length(keys) != length(unique(keys))) {
      cli::cli_abort(
        "All entries must have unique source::family combinations."
      )
    }

    NULL
  }
)
