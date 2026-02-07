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
  validator = function(self) {
    entries <- self@entries
    # entiers is either an empty list or must have at least one element that is a CacheEntry

    # enties is a list
    if (!is.list(entries)) {
      cli::cli_abort("self@entries must be a list.")
    }

    if (length(entries) == 0) {
      return(NULL)
    }

    # check if all entries are CacheEntry objects
    res <- lapply(entries, function(e) {
      S7::S7_inherits(e, class = CacheEntry)
    }) |>
      unlist()
    if (!all(res)) {
      cli::cli_abort(
        "All elements of self@entries must be <CacheEntry> objects."
      )
    }

    # check if all entries have unique family names
    fams <- vapply(entries, function(e) e@family, character(1))
    if (length(fams) != length(unique(fams))) {
      cli::cli_abort(
        "All entries in self@entries must have unique family names."
      )
    }

    NULL
  }
)
