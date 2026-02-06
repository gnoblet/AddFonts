#' Add a font to the local cache and register it for use
#'
#' Ensure a font is available locally: try the registry, otherwise
#' download/convert and register the font so it can be used by plotting
#' devices. Returns (invisibly) the list of local file paths.
#'
#' @typed name: character(1)
#'   Name of the font as known to the provider.
#' @typed provider: character(1)
#'   Provider id/name (default: "bunny").
#' @typed family: character | NULL
#'   Optional family name to register the font under (default: NULL).
#' @typed regular.wt: numeric(1)
#'   Regular weight to request (default: 400).
#' @typed bold.wt: numeric(1)
#'   Bold weight to request (default: 700).
#' @typed subset: character(1)
#'   Glyph subset to request (default: "latin").
#' @typedreturn list
#'   Invisibly returns a list with paths for `regular`, `italic`, `bold`
#'   and `bolditalic` variants, or throws an error on failure.
#' @export
add_font <- function(
    name,
    provider = "bunny",
    family = NULL,
    regular.wt = 400,
    bold.wt = 700,
    subset = "latin"
) {
    # Basic validation (keep concise; helpers exist for heavy checks)
    if (!is.character(name) || length(name) != 1 || !nzchar(name)) {
        cli::cli_abort("{.arg name} must be a non-empty string.")
    }
    if (!is.character(provider) || length(provider) != 1 || !nzchar(provider)) {
        cli::cli_abort("{.arg provider} must be a non-empty string.")
    }
    if (
        !is.null(family) &&
            (!is.character(family) || length(family) != 1 || !nzchar(family))
    ) {
        cli::cli_abort("{.arg family} must be NULL or a non-empty string.")
    }
    if (!is.numeric(regular.wt) || length(regular.wt) != 1) {
        cli::cli_abort("{.arg regular.wt} must be a single numeric weight.")
    }
    if (!is.numeric(bold.wt) || length(bold.wt) != 1) {
        cli::cli_abort("{.arg bold.wt} must be a single numeric weight.")
    }
    if (!is.character(subset) || length(subset) != 1 || !nzchar(subset)) {
        cli::cli_abort("{.arg subset} must be a non-empty string.")
    }

    # Prepare identifiers and provider object
    provider_obj <- get_provider_details(provider)
    font_id <- safe_id(name)
    family_name <- if (is.null(family)) name else family
    cache_dir <- get_cache_dir()

    # Try to read cache index (proceed if cache missing/corrupt)
    cel <- cache_read(cache_dir = cache_dir, quiet = TRUE)

    # if cel is not an empty list, check for existing entry
    if (!length(cel@entries) == 0) {
        got <- cache_get(cel, families = family_name)
        if (!is.null(got) && length(got) >= 1) {
            existing_entry <- got[[1]]
        }
    }

    # If cached, try register from cache; the helper returns file list or NULL
    if (!is.null(existing_entry)) {
        files <- register_from_cache(existing_entry, family_name)
        if (!is.null(files)) {
            return(invisible(files))
        }

        # Stale cache entry: remove entry (but keep files on disk), then continue
        cli::cli_warn(
            "Stale cache entry for {.val {family_name}} — removing index entry and re-downloading."
        )
        if (!is.null(cel)) {
            cel_new <- cache_remove(
                cel,
                families = family_name,
                remove_files = FALSE,
                cache_dir = cache_dir
            )
            cache_write(cel_new, cache_dir = cache_dir, quiet = TRUE)
        }
    }

    # Delegate download + conversion + registration to helper which will update cache
    files_entry <- register_from_download(
        provider = provider_obj,
        name = name,
        font_id = font_id,
        family_name = family_name,
        regular.wt = regular.wt,
        bold.wt = bold.wt,
        subset = subset,
        cache_dir = cache_dir
    )

    if (is.null(files_entry)) {
        cli::cli_abort(
            "No font available for {.val {name}} from provider {.val {provider}}."
        )
    }

    invisible(files_entry)
}
