## Helper: register_from_cache
#'
#' Validate a cache entry and register the font with sysfonts if the
#' required files exist. Returns the prepared `files` list or `NULL` when
#' registration cannot proceed.
#'
#' This is the ONLY function that calls sysfonts::font_add(). It does not
#' print success messages - callers should handle user feedback.
#'
#' @typed entry: CacheEntry
#'   Cache entry object with family and metadata.
#' @typed regular.wt: numeric(1)
#'   Regular weight to use for regular and italic variants (default: 400).
#' @typed bold.wt: numeric(1)
#'   Bold weight to use for bold and bolditalic variants (default: 700).
#'
#' @typedreturn list | NULL
#'   Prepared `files` list (with `regular`, `italic`, `bold`, `bolditalic`) or `NULL`.
register_from_cache <- function(entry, regular.wt = 400, bold.wt = 700) {
    #------ Arg check
    if (!S7::S7_inherits(entry, CacheEntry)) {
        cli::cli_abort("{.arg entry} must be a <CacheEntry> object.")
    }

    if (!is.numeric(regular.wt) || length(regular.wt) != 1) {
        cli::cli_abort("{.arg regular.wt} must be a single numeric weight.")
    }
    if (!is.numeric(bold.wt) || length(bold.wt) != 1) {
        cli::cli_abort("{.arg bold.wt} must be a single numeric weight.")
    }

    #------ Extract metadata
    family_name <- entry@family
    meta <- entry@meta
    files <- meta@files

    # Ensure we have files metadata
    if (is.null(files) || length(files) == 0) {
        return(NULL)
    }

    # Build weight keys to look for
    regular_key <- as.character(regular.wt)
    regular_italic_key <- paste0(regular.wt, "italic")
    bold_key <- as.character(bold.wt)
    bold_italic_key <- paste0(bold.wt, "italic")

    # Get files for requested weights (or NULL if not available)
    regular_file <- files[[regular_key]]
    italic_file <- files[[regular_italic_key]]
    bold_file <- files[[bold_key]]
    bolditalic_file <- files[[bold_italic_key]]

    # Check if regular font file exists (required)
    if (is.null(regular_file) || !fs::file_exists(regular_file)) {
        return(NULL)
    }

    # Build variant list with fallbacks for missing files
    files_to_register <- list(
        regular = regular_file,
        italic = italic_file,
        bold = bold_file,
        bolditalic = bolditalic_file
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

    return(invisible(files_to_register))
}
