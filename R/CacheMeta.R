#' S7-backed cache metadata (CacheMeta)
#'
#' @typed source: character(1)
#'  Name of the provider or source that produced the cached font files.
#'
#' @typed files: list(1+)
#'  A non-empty named list of file paths. Names are either:
#'  - Weight identifiers: `"400"`, `"400italic"`, `"700"`, etc. (weight-based providers)
#'  - Variant keys: `"regular"`, `"italic"`, `"bold"`, `"bolditalic"` (file-based providers)
#'  All keys must follow the same scheme — mixing is not allowed.
#'
#' @details
#' The key scheme is determined by the provider type. Weight-based providers (e.g. Bunny)
#' use numeric weight keys. File-based providers (e.g. Bye Bye Binary) use symbolic variant keys.
#' Registration functions detect the scheme automatically.
#'
#' @typedreturn S7_object
#'  A validated S7 `CacheMeta` object.
#'
#' @export
CacheMeta <- S7::new_class(
  "CacheMeta",
  properties = list(
    source = S7::class_character,
    files = S7::class_list
  ),
  validator = function(self) {
    # source is a non-empty string
    assert_null_or_non_empty_string(self@source, allow_null = FALSE)

    files <- self@files
    # - non-empty list of non-empty character strings
    if (length(files) == 0) {
      cli::cli_abort("self@files must be a non-empty list.")
    }
    for (f in files) {
      if (!is.character(f) || length(f) < 1 || !nzchar(f[1])) {
        cli::cli_abort(
          "self@files must be a list of non-empty character strings."
        )
      }
    }
    # = right path pattern
    lapply(files, function(f) {
      assert_pattern_with_ext(f, ext = ".ttf")
    })

    # Validate file key names
    file_names <- names(files)
    if (any(is.na(file_names)) || is.null(file_names) || any(file_names == "")) {
      cli::cli_abort(
        "All elements of self@files must be named with weight or variant keys."
      )
    }

    symbolic_keys <- c("regular", "italic", "bold", "bolditalic")
    weight_rx <- "^(100|200|300|400|500|600|700|800|900)(?:italic)?$"

    is_symbolic <- file_names %in% symbolic_keys
    is_weight   <- grepl(weight_rx, file_names)

    if (!all(is_symbolic | is_weight)) {
      bad <- file_names[!(is_symbolic | is_weight)]
      cli::cli_abort(c(
        "File names in {.arg self@files} must be weight keys or variant keys.",
        "i" = "Weight keys: 100\u2013900 with optional {.val italic} suffix (e.g. {.val 400}, {.val 700italic}).",
        "i" = "Variant keys: {.val regular}, {.val italic}, {.val bold}, {.val bolditalic}.",
        "x" = "Invalid key{?s}: {.val {bad}}"
      ))
    }

    if (any(is_symbolic) && any(is_weight)) {
      cli::cli_abort(c(
        "self@files must use either weight keys or variant keys, not both.",
        "i" = "Weight-based providers use numeric keys (e.g. {.val 400}, {.val 700}).",
        "i" = "File-based providers use variant keys ({.val regular}, {.val bold}, \u2026)."
      ))
    }

    NULL
  }
)
