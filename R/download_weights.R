#' Download font files for specified weights
#'
#' Downloads normal and italic variants for each weight and returns a named
#' list with weight-based keys.
#'
#' @typed provider: FontProvider
#'   Provider object used for downloads.
#' @typed name: character(1)
#'   Font name at the provider.
#' @typed weights: numeric
#'   Vector of weights to download.
#' @typed subset: character(1)
#'   Glyph subset to request.
#' @typed cache_dir: character(1)
#'   Cache directory to use.
#' @typed quiet: logical(1)
#'   Whether to suppress download messages (default: TRUE).
#'
#' @typedreturn list
#'   Named list where names are weight identifiers (e.g., "400", "700italic")
#'   and values are file paths.
#'
download_weights <- function(
    provider,
    name,
    weights,
    subset,
    cache_dir,
    quiet = TRUE
) {
    #------ Arg check
    if (!S7::S7_inherits(provider, FontProvider)) {
        cli::cli_abort("{.arg provider} must be a <FontProvider> object.")
    }

    assert_null_or_non_empty_string(name, allow_null = FALSE)

    if (!is.numeric(weights) || length(weights) == 0) {
        cli::cli_abort("{.arg weights} must be a non-empty numeric vector.")
    }

    assert_null_or_non_empty_string(subset, allow_null = FALSE)
    assert_null_or_non_empty_string(cache_dir, allow_null = FALSE)

    if (!is.logical(quiet) || length(quiet) != 1) {
        cli::cli_abort("{.arg quiet} must be a logical scalar.")
    }

    #------ Do stuff
    files <- list()

    for (wt in weights) {
        # Download normal variant
        normal <- download_variant_generic(
            provider,
            name,
            wt,
            "normal",
            subset,
            cache_dir,
            quiet = quiet
        )

        if (!is.null(normal)) {
            files[[as.character(wt)]] <- normal
        }

        # Download italic variant
        italic <- download_variant_generic(
            provider,
            name,
            wt,
            "italic",
            subset,
            cache_dir,
            quiet = TRUE # Always quiet for italic variants
        )

        if (!is.null(italic)) {
            files[[paste0(wt, "italic")]] <- italic
        }
    }

    return(files)
}
