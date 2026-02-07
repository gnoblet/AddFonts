## Helper: register_from_cache
#'
#' Validate a cache entry and register the font with sysfonts if the
#' required files exist. Returns the prepared `files` list or `NULL` when
#' registration cannot proceed.
#'
#' @typed entry: CacheEntry
#'   Cache entry object with family and metadata.
#'
#' @typedreturn list | NULL
#'   Prepared `files` list (with `regular`, `italic`, `bold`, `bolditalic`) or `NULL`.
register_from_cache <- function(entry) {
    #------ Arg check
    if (!S7::S7_inherits(entry, CacheEntry)) {
        cli::cli_abort("{.arg entry} must be a <CacheEntry> object.")
    }

    #------ Extract metadata
    family_name <- entry@family
    meta <- entry@meta
    files <- meta@files

    # Ensure we have files metadata
    if (is.null(files) || length(files) == 0) {
        return(NULL)
    }

    # Check if regular font file exists (required)
    if (is.null(files$regular) || !fs::file_exists(files$regular)) {
        return(NULL)
    }

    # Build variant list with fallbacks for missing files
    files_to_register <- list(
        regular = files$regular,
        italic = files$italic,
        bold = files$bold,
        bolditalic = files$bolditalic
    )

    # Apply fallbacks for missing variants
    if (
        is.null(files_to_register$italic) ||
            !fs::file_exists(files_to_register$italic)
    ) {
        files_to_register$italic <- files_to_register$regular
    }
    if (
        is.null(files_to_register$bold) ||
            !fs::file_exists(files_to_register$bold)
    ) {
        files_to_register$bold <- files_to_register$regular
    }
    if (
        is.null(files_to_register$bolditalic) ||
            !fs::file_exists(files_to_register$bolditalic)
    ) {
        # Prefer bold over italic if available
        if (
            !is.null(files_to_register$bold) &&
                fs::file_exists(files_to_register$bold)
        ) {
            files_to_register$bolditalic <- files_to_register$bold
        } else if (
            !is.null(files_to_register$italic) &&
                fs::file_exists(files_to_register$italic)
        ) {
            files_to_register$bolditalic <- files_to_register$italic
        } else {
            files_to_register$bolditalic <- files_to_register$regular
        }
    }

    # Register with sysfonts
    sysfonts::font_add(
        family = family_name,
        regular = files_to_register$regular,
        italic = files_to_register$italic,
        bold = files_to_register$bold,
        bolditalic = files_to_register$bolditalic
    )

    # Notify user
    cli::cli_alert_success(
        "Font {.val {family_name}} registered from cache."
    )

    return(invisible(files_to_register))
}
