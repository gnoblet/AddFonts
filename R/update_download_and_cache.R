#' Download missing weights and update an existing cache entry
#'
#' Downloads missing font weights and updates the cache entry.
#' Does NOT register the font - use register_from_cache() after this.
#'
#' @typed entry: CacheEntry
#'   Existing cache entry to update.
#' @typed provider: FontProvider
#'   Provider object used for downloads.
#' @typed name: character(1)
#'   Font name at the provider.
#' @typed family_name: character(1)
#'   Family name for the font.
#' @typed missing_weights: numeric
#'   Vector of weights to download and add to cache.
#' @typed subset: character(1)
#'   Glyph subset to request (default: "latin").
#' @typed cache_dir: character | NULL
#'   Cache directory to use.
#' @typed cel: CacheEntryList
#'   Current cache entry list to update.
#'
#' @typedreturn CacheEntry | NULL
#'   Updated cache entry with new weights (NOT registered), or NULL on failure.
#'
update_download_and_cache <- function(
    entry,
    provider,
    name,
    family_name,
    missing_weights,
    subset = "latin",
    cache_dir = NULL,
    cel = NULL
) {
    #------ Arg check
    if (!S7::S7_inherits(entry, CacheEntry)) {
        cli::cli_abort("{.arg entry} must be a <CacheEntry> object.")
    }
    if (!S7::S7_inherits(provider, FontProvider)) {
        cli::cli_abort("{.arg provider} must be a <FontProvider> object.")
    }
    if (!is.numeric(missing_weights) || length(missing_weights) == 0) {
        cli::cli_abort(
            "{.arg missing_weights} must be a non-empty numeric vector."
        )
    }

    if (is.null(cache_dir)) {
        cache_dir <- get_cache_dir()
    }

    #------ Download missing weight variants using helper
    new_files <- download_weights(
        provider,
        name,
        missing_weights,
        subset,
        cache_dir,
        quiet = TRUE
    )

    # Return NULL if no new files were downloaded
    if (length(new_files) == 0) {
        return(NULL)
    }

    # Merge with existing files
    updated_files <- c(entry@meta@files, new_files)

    #------ Create updated cache entry
    updated_meta <- CacheMeta(
        source = entry@meta@source,
        family_id = entry@meta@family_id,
        files = updated_files
    )

    updated_entry <- CacheEntry(
        family = family_name,
        meta = updated_meta
    )

    #------ Update cache if cel provided
    if (!is.null(cel)) {
        cel <- cache_set(cel, family_name, updated_meta)
        cache_write(cel, cache_dir = cache_dir, quiet = TRUE)
    }

    return(updated_entry)
}
