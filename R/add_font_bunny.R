#' Download and Register a Font from Bunny Fonts
#'
#' Downloads a font from [fonts.bunny.net](https://fonts.bunny.net/), caches it locally,
#' and registers it for use in R graphics devices via `sysfonts` and `showtext`.
#' This provides a privacy-focused alternative to Google Fonts.
#'
#' Font files are downloaded as WOFF2 and automatically converted to TTF format for
#' compatibility with `sysfonts`. This requires the `woff2_decompress` command-line tool
#' to be installed on your system.
#'
#' @typed name: character(1)
#'   The font name as listed on Bunny Fonts (e.g., "open-sans").
#'   Can be the family ID (lowercase with hyphens) or display name (case-insensitive).
#' @typed family: character(1) or NULL
#'   The family name to register in R (default: `NULL`, uses `name`).
#' @typed wt: numeric or NULL
#'   Font weights to download (e.g., c(400, 700)).
#'   Use a vector to specify only certain weights (e.g., c(300, 500, 700))
#'   (default: `NULL`, downloads all available weights).
#' @typed styles: character(1)
#'   Which styles to download: "normal", "italic", or "both".
#'   Set to "normal" for regular styles only, "italic" for italic only,
#'   or "both" for all available styles (default: `"both"`).
#' @typed regular.wt: numeric(1) or NULL
#'   Which weight to use as the regular font face for `sysfonts::font_add()`
#'   (default: `NULL`, uses the first weight in `wt`).
#' @typed bold.wt: numeric(1) or NULL
#'   Which weight to use as the bold font face for `sysfonts::font_add()`
#'   (default: `NULL`, uses the last weight in `wt`).
#' @typed subset: character(1) or NULL
#'   Font subset to use (e.g., "latin", "latin-ext")
#'   (default: `NULL`, uses the font's default subset).
#' @typed cache_dir: character(1) or NULL
#'   Directory to cache downloaded fonts
#'   (default: `NULL`, uses platform-appropriate cache directory via `get_font_cache_dir()`).
#' @param ... Additional arguments passed to `sysfonts::font_add()`.
#'
#' @section System Requirements:
#'
#' This function requires the `woff2_decompress` command-line tool to convert
#' downloaded WOFF2 files to TTF format. Install it using:
#'
#' - **macOS:** `brew install woff2`
#' - **Debian/Ubuntu:** `sudo apt install woff2`
#' - **Fedora/RHEL:** `sudo dnf install woff2-tools`
#' - **Arch Linux:** `sudo pacman -S woff2`
#' - **Windows:** Build from \url{https://github.com/google/woff2}
#'
#' @typedreturn: list
#'   Invisibly returns a list of paths to the registered font files.
#' @export
#'
#' @examples
#' \dontrun{
#' # Add a font with all weights and styles (default)
#' add_font_bunny("open-sans")
#'
#' # Add only specific weights
#' add_font_bunny("roboto", wt = c(300, 400, 700))
#'
#' # Add only normal (non-italic) styles
#' add_font_bunny("roboto", styles = "normal")
#'
#' # Add specific weights in italic only
#' add_font_bunny("merriweather", wt = c(400, 700), styles = "italic")
#'
#' # Specify which weights to use for regular and bold
#' add_font_bunny("roboto", wt = c(300, 400, 700), regular.wt = 400, bold.wt = 700)
#'
#' # Specify custom family name
#' add_font_bunny("source-code-pro", family = "SourceCode", wt = 400)
#'
#' # Enable showtext and use the font
#' showtext::showtext_auto()
#' plot(1:10, main = "This uses fonts from Bunny Fonts!")
#' }
add_font_bunny <- function(
  name,
  family = NULL,
  wt = NULL,
  styles = "both",
  regular.wt = NULL,
  bold.wt = NULL,
  subset = NULL,
  cache_dir = NULL,
  ...
) {
  # Parameter validation
  if (!is.character(name) || length(name) != 1 || nchar(name) == 0) {
    cli::cli_abort("{.arg name} must be a non-empty string.")
  }
  if (
    !is.null(family) &&
      (!is.character(family) || length(family) != 1 || nchar(family) == 0)
  ) {
    cli::cli_abort("{.arg family} must be a non-empty string or NULL.")
  }
  if (!is.null(wt)) {
    if (
      !is.numeric(wt) || any(wt < 100) || any(wt > 900) || any(wt %% 1 != 0)
    ) {
      cli::cli_abort(
        "{.arg wt} must be NULL or integer values between 100 and 900."
      )
    }
  }
  if (
    !is.character(styles) ||
      length(styles) != 1 ||
      !styles %in% c("normal", "italic", "both")
  ) {
    cli::cli_abort(
      "{.arg styles} must be one of {.val normal}, {.val italic}, or {.val both}."
    )
  }
  if (!is.null(regular.wt)) {
    if (
      !is.numeric(regular.wt) ||
        length(regular.wt) != 1 ||
        regular.wt < 100 ||
        regular.wt > 900 ||
        regular.wt %% 1 != 0
    ) {
      cli::cli_abort(
        "{.arg regular.wt} must be NULL or a single integer value between 100 and 900."
      )
    }
  }
  if (!is.null(bold.wt)) {
    if (
      !is.numeric(bold.wt) ||
        length(bold.wt) != 1 ||
        bold.wt < 100 ||
        bold.wt > 900 ||
        bold.wt %% 1 != 0
    ) {
      cli::cli_abort(
        "{.arg bold.wt} must be NULL or a single integer value between 100 and 900."
      )
    }
  }
  if (
    !is.null(subset) &&
      (!is.character(subset) || length(subset) != 1 || nchar(subset) == 0)
  ) {
    cli::cli_abort("{.arg subset} must be a non-empty string or NULL.")
  }
  if (
    !is.null(cache_dir) &&
      (!is.character(cache_dir) ||
        length(cache_dir) != 1 ||
        nchar(cache_dir) == 0)
  ) {
    cli::cli_abort("{.arg cache_dir} must be a non-empty string or NULL.")
  }

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
    cli::cli_abort(c(
      "Font {.val {name}} not found in Bunny Fonts.",
      "i" = "Use {.fn font_search_bunny} to find fonts."
    ))
  }
  font_info <- fonts[idx[1], ]

  # Use the font family ID for URLs (lowercase with hyphens)
  font_id <- font_info$family

  # Determine subset
  if (is.null(subset)) {
    subset <- font_info$defSubset
  }

  # Get available weights and styles from font info
  available_weights <- font_info$weights[[1]]
  available_styles <- font_info$styles[[1]]

  # Determine which weights to download
  weights_to_download <- if (is.null(wt)) {
    available_weights
  } else {
    # Validate requested weights are available
    invalid_weights <- setdiff(wt, available_weights)
    if (length(invalid_weights) > 0) {
      invalid_str <- paste(invalid_weights, collapse = ", ")
      available_str <- paste(available_weights, collapse = ", ")
      weight_word <- if (length(invalid_weights) == 1) "Weight" else "Weights"
      cli::cli_abort(c(
        "{weight_word} {.val {invalid_str}} not available for font {.val {font_info$familyName}}.",
        "i" = "Available weights: {.val {available_str}}"
      ))
    }
    wt
  }

  # Validate and set regular.wt and bold.wt
  if (!is.null(regular.wt) && !regular.wt %in% weights_to_download) {
    cli::cli_abort(c(
      "{.arg regular.wt} value {.val {regular.wt}} is not in the weights to download.",
      "i" = "Weights to download: {.val {weights_to_download}}"
    ))
  }
  if (!is.null(bold.wt) && !bold.wt %in% weights_to_download) {
    cli::cli_abort(c(
      "{.arg bold.wt} value {.val {bold.wt}} is not in the weights to download.",
      "i" = "Weights to download: {.val {weights_to_download}}"
    ))
  }

  # Set defaults for regular and bold weights
  regular_weight <- if (!is.null(regular.wt)) {
    regular.wt
  } else {
    weights_to_download[1]
  }
  bold_weight <- if (!is.null(bold.wt)) {
    bold.wt
  } else {
    weights_to_download[length(weights_to_download)]
  }

  # Determine which styles to download
  styles_to_download <- switch(
    styles,
    "normal" = "normal",
    "italic" = if ("italic" %in% available_styles) "italic" else character(0),
    "both" = available_styles
  )

  if (length(styles_to_download) == 0) {
    cli::cli_abort(c(
      "Style {.val {styles}} not available for font {.val {font_info$familyName}}.",
      "i" = "Available styles: {.val {available_styles}}"
    ))
  }

  # Download all requested weight/style combinations
  font_paths <- list()
  font_args <- list()
  # font_args <- list(family = family)

  for (weight in weights_to_download) {
    for (style in styles_to_download) {
      font_file <- .download_bunny_font(
        font_id = font_id,
        weight = weight,
        style = style,
        subset = subset,
        cache_dir = cache_dir,
        family = family
      )

      # Create a descriptive key for the font path
      path_key <- sprintf("%s_%d", style, weight)
      font_paths[[path_key]] <- font_file

      # For sysfonts registration, we need specific names
      # Register specified regular weight, or first weight if not specified
      if (weight == regular_weight) {
        if (style == "normal") {
          font_args$regular <- font_file
        } else if (style == "italic") {
          font_args$italic <- font_file
        }
      }
      # Register specified bold weight, or last weight if not specified
      if (weight == bold_weight) {
        if (style == "normal") {
          font_args$bold <- font_file
        } else if (style == "italic") {
          font_args$bolditalic <- font_file
        }
      }
    }
  }

  # Ensure we have at least regular defined
  if (is.null(font_args$regular)) {
    # Use the first available file
    font_args$regular <- font_paths[[1]]
  }

  # Register font with sysfonts
  sysfonts::font_add(
    family = family,
    regular = font_args$regular,
    italic = font_args$italic,
    bold = font_args$bold,
    bolditalic = font_args$bolditalic
  )

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
  ttf_file <- fs::path_ext_set(font_file, "ttf")

  # Ensure cache directory exists (be defensive: caller may not have created it)
  if (!fs::dir_exists(fs::path_dir(font_file))) {
    fs::dir_create(fs::path_dir(font_file), recurse = TRUE)
  }

  # If TTF already exists, return it (skip download and conversion)
  if (fs::file_exists(ttf_file)) {
    return(ttf_file)
  }

  # Download WOFF2 if not cached
  if (!fs::file_exists(font_file)) {
    cli::cli_alert_info("Downloading: {.file {basename(font_file)}}")

    resp <- tryCatch(
      httr2::request(font_url) |>
        httr2::req_user_agent("addfonts R package") |>
        httr2::req_perform(path = font_file),
      error = function(e) {
        cli::cli_abort(c(
          "Failed to download font from {.url {font_url}}",
          "x" = conditionMessage(e)
        ))
      }
    )
  }

  # Convert WOFF2 to TTF for compatibility with sysfonts
  # Most FreeType builds don't support WOFF2 without Brotli
  cli::cli_alert_info("Converting to TTF: {.file {basename(ttf_file)}}")
  tryCatch(
    .woff2_to_ttf(font_file, overwrite = FALSE),
    error = function(e) {
      cli::cli_abort(c(
        "Failed to convert {.file {basename(font_file)}} to TTF.",
        "i" = "Install woff2 tools for your system:",
        "i" = "  macOS: {.code brew install woff2}",
        "i" = "  Linux (Debian/Ubuntu): {.code sudo apt install woff2}",
        "i" = "  Linux (Fedora/RHEL): {.code sudo dnf install woff2-tools}",
        "i" = "  Windows: Build from https://github.com/google/woff2",
        "x" = conditionMessage(e)
      ))
    }
  )

  ttf_file
}


#' Convert a .woff2 font to .ttf using the system 'woff2_decompress' tool
#'
#' This is an internal helper. It will attempt to run the `woff2_decompress`
#' command-line tool (from https://github.com/google/woff2) to convert a
#' downloaded `.woff2` file to a `.ttf`. If the tool is not available an
#' informative error is raised explaining how to install it.
#'
#' @param font_file Path to an existing .woff2 file
#' @param overwrite Logical, whether to overwrite an existing output file.
#' @return Path to the .ttf file (invisibly).
#' @noRd
.woff2_to_ttf <- function(font_file, overwrite = FALSE) {
  if (!fs::file_exists(font_file)) {
    cli::cli_abort("Font file not found: {.file {font_file}}")
  }
  if (tolower(fs::path_ext(font_file)) != "woff2") {
    cli::cli_abort("Expected a .woff2 file but got: {.file {font_file}}")
  }

  out <- fs::path_ext_set(font_file, "ttf")

  if (fs::file_exists(out) && !isTRUE(overwrite)) {
    cli::cli_alert_info("Using existing converted file: {.file {out}}")
    return(invisible(out))
  }

  woff2_cmd <- Sys.which("woff2_decompress")
  if (!nzchar(woff2_cmd)) {
    cli::cli_abort(c(
      "System tool {.val woff2_decompress} not found.",
      "i" = "Install the tool and ensure it's on your PATH.",
      "i" = "On Debian/Ubuntu: {.code sudo apt install woff2}",
      "i" = "On Fedora/RHEL: {.code sudo dnf install woff2-tools}",
      "i" = "On macOS (Homebrew): {.code brew install woff2}",
      "i" = "Or build from: https://github.com/google/woff2"
    ))
  }

  # Run the conversion: woff2_decompress input.woff2
  res <- system2(
    woff2_cmd,
    args = font_file,
    stdout = TRUE,
    stderr = TRUE
  )
  status <- attr(res, "status")
  if (!is.null(status) && status != 0) {
    cli::cli_abort(c(
      "Failed to convert {.file {font_file}} to TTF using {.val woff2_decompress}.",
      "x" = paste(res, collapse = "\n")
    ))
  }

  if (!fs::file_exists(out)) {
    cli::cli_abort(
      "Conversion finished but output file not found: {.file {out}}"
    )
  }

  invisible(out)
}
