#' Download and Register a Font from Bunny Fonts
#'
#' Downloads a font from [fonts.bunny.net](https://fonts.bunny.net/), caches it locally,
#' and registers it for use in R graphics devices via `sysfonts` and `showtext`.
#' This provides a privacy-focused alternative to Google Fonts.
#'
#' @param name Character. The font name as listed on Bunny Fonts (e.g., "open-sans").
#'   Can be the family ID (lowercase with hyphens) or display name (case-insensitive).
#' @param family Character. The family name to register in R. Defaults to `name`.
#' @param regular.wt Integer. The weight of the regular font variant (default: 400).
#' @param bold.wt Integer. The weight of the bold font variant (default: 700).
#' @param italic Logical. Whether to download italic variant (default: TRUE if available).
#' @param subset Character. Font subset to use (e.g., "latin", "latin-ext").
#'   Defaults to the font's default subset.
#' @param cache_dir Character. Directory to cache downloaded fonts. Defaults to
#'   a platform-appropriate cache directory (see `get_font_cache_dir()`).
#' @param ... Additional arguments passed to `sysfonts::font_add()`.
#'
#' @return Invisibly returns a list of paths to the registered font files.
#' @export
#'
#' @examples
#' \dontrun{
#' # Add a font by its family ID
#' add_font_bunny("open-sans")
#'
#' # Or use the display name
#' add_font_bunny("Open Sans")
#'
#' # Specify custom family name and weight
#' add_font_bunny("roboto", family = "Roboto", regular.wt = 300)
#'
#' # Enable showtext and use the font
#' showtext::showtext_auto()
#' plot(1:10, main = "This uses Open Sans from Bunny Fonts!")
#' }
add_font_bunny <- function(
  name,
  family = NULL,
  regular.wt = 400,
  bold.wt = 700,
  italic = TRUE,
  subset = NULL,
  cache_dir = NULL,
  ...
) {
  # Parameter validation
  checkmate::assert_string(name, min.chars = 1)
  checkmate::assert_string(family, null.ok = TRUE, min.chars = 1)
  checkmate::assert_integerish(regular.wt, len = 1, lower = 100, upper = 900)
  checkmate::assert_integerish(bold.wt, len = 1, lower = 100, upper = 900)
  checkmate::assert_logical(italic, len = 1)
  checkmate::assert_string(subset, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(cache_dir, null.ok = TRUE, min.chars = 1)

  # Set default family
  if (is.null(family)) {
    family <- name
  }

  # Set default cache directory using platform-appropriate location
  if (is.null(cache_dir)) {
    cache_dir <- get_font_cache_dir()
  } else {
    # If user provides custom cache_dir, ensure it exists
    if (!fs::dir_exists(cache_dir)) {
      fs::dir_create(cache_dir, recurse = TRUE)
    }
  }

  # Get font list from bundled database
  fonts <- font_list_bunny()

  # Try to match by family ID or display name
  idx <- which(tolower(fonts$family) == tolower(gsub(" ", "-", name)))
  if (length(idx) == 0) {
    # Try matching by familyName
    idx <- which(tolower(fonts$familyName) == tolower(name))
  }
  if (length(idx) == 0) {
    stop(sprintf(
      "Font '%s' not found in Bunny Fonts. Use font_search_bunny() to find fonts.",
      name
    ))
  }
  font_info <- fonts[idx[1], ]

  # Use the font family ID for URLs (lowercase with hyphens)
  font_id <- font_info$family

  # Determine subset
  if (is.null(subset)) {
    subset <- font_info$defSubset
  }

  # Check if requested weights are available
  available_weights <- font_info$weights[[1]]
  available_styles <- font_info$styles[[1]]

  if (!(regular.wt %in% available_weights)) {
    stop(sprintf(
      "Weight %d not available for font '%s'. Available weights: %s",
      regular.wt,
      font_info$familyName,
      paste(available_weights, collapse = ", ")
    ))
  }

  # Download regular font
  regular_file <- .download_bunny_font(
    font_id = font_id,
    weight = regular.wt,
    style = "normal",
    subset = subset,
    cache_dir = cache_dir,
    family = family
  )

  font_paths <- list(regular = regular_file)
  font_args <- list(family = family, regular = regular_file)

  # Download bold if weight is available
  bold_file <- NULL
  if (bold.wt %in% available_weights && bold.wt != regular.wt) {
    bold_file <- .download_bunny_font(
      font_id = font_id,
      weight = bold.wt,
      style = "normal",
      subset = subset,
      cache_dir = cache_dir,
      family = family
    )
    font_paths$bold <- bold_file
    font_args$bold <- bold_file
  }

  # Download italic variants if requested and available
  if (italic && "italic" %in% available_styles) {
    italic_file <- .download_bunny_font(
      font_id = font_id,
      weight = regular.wt,
      style = "italic",
      subset = subset,
      cache_dir = cache_dir,
      family = family
    )
    font_paths$italic <- italic_file
    font_args$italic <- italic_file

    # Bold italic
    if (!is.null(bold_file) && bold.wt %in% available_weights) {
      bolditalic_file <- .download_bunny_font(
        font_id = font_id,
        weight = bold.wt,
        style = "italic",
        subset = subset,
        cache_dir = cache_dir,
        family = family
      )
      font_paths$bolditalic <- bolditalic_file
      font_args$bolditalic <- bolditalic_file
    }
  }

  # Register font with sysfonts
  do.call(sysfonts::font_add, c(font_args, list(...)))

  invisible(font_paths)
}

#' Download a single Bunny Font file
#' @noRd
.download_bunny_font <- function(
  font_id,
  weight,
  style,
  subset,
  cache_dir,
  family
) {
  # Construct the CDN URL for woff2 format
  # Pattern: https://fonts.bunny.net/{font-id}/files/{font-id}-{subset}-{weight}-{style}.woff2
  style_suffix <- if (style == "italic") "italic" else "normal"
  font_url <- sprintf(
    "https://fonts.bunny.net/%s/files/%s-%s-%d-%s.woff2",
    font_id,
    font_id,
    subset,
    weight,
    style_suffix
  )

  # Create cache filename
  cache_filename <- sprintf(
    "%s-%s-%d-%s.woff2",
    gsub("[^a-zA-Z0-9-]", "-", font_id),
    subset,
    weight,
    style_suffix
  )
  font_file <- fs::path(cache_dir, cache_filename)

  # Download if not cached
  if (!fs::file_exists(font_file)) {
    message(sprintf("Downloading: %s", basename(font_file)))
    resp <- tryCatch(
      httr::GET(
        font_url,
        httr::write_disk(font_file, overwrite = TRUE),
        httr::user_agent("addfonts R package")
      ),
      error = function(e) {
        stop(sprintf(
          "Failed to download font from %s: %s",
          font_url,
          e$message
        ))
      }
    )

    if (httr::http_error(resp)) {
      fs::file_delete(font_file)
      stop(sprintf(
        "Failed to download font file (HTTP %d): %s",
        httr::status_code(resp),
        font_url
      ))
    }
  }

  font_file
}
