#' S7-backed cache metadata (CacheMeta)
#'
#' @typed source: character(1)
#'  Name of the provider or source that produced the cached font files.
#'
#' @typed key_scheme: character(1)
#'  Key scheme used in `files`: `"weight"` for numeric weight keys (e.g. `"400"`, `"700italic"`) or `"symbolic"` for variant keys (`"regular"`, `"bold"`, etc.).
#'
#' @typed files: list(1+)
#'  A non-empty named list of file paths. Names must follow the scheme declared by `key_scheme`.
#'
#' @typedreturn S7_object
#'  A validated S7 `CacheMeta` object.
#'
#' @export
CacheMeta <- S7::new_class(
  "CacheMeta",
  properties = list(
    source = S7::class_character,
    key_scheme = S7::class_character,
    files = S7::class_list,
    failed_keys = S7::class_character
  ),
  constructor = function(source, files, key_scheme = NULL, failed_keys = character(0)) {
    if (is.null(key_scheme)) {
      symbolic_keys <- c("regular", "italic", "bold", "bolditalic")
      key_scheme <- if (any(names(files) %in% symbolic_keys)) "symbolic" else "weight"
    }
    S7::new_object(
      S7::S7_object(),
      source = source,
      key_scheme = key_scheme,
      files = files,
      failed_keys = failed_keys
    )
  },
  validator = function(self) {
    assert_null_or_non_empty_string(self@source, allow_null = FALSE)

    if (!self@key_scheme %in% c("weight", "symbolic")) {
      cli::cli_abort(
        "@key_scheme must be {.val weight} or {.val symbolic}, not {.val {self@key_scheme}}."
      )
    }

    files <- self@files
    if (length(files) == 0) {
      cli::cli_abort("self@files must be a non-empty list.")
    }
    for (f in files) {
      if (!is.character(f) || length(f) < 1 || !nzchar(f[1])) {
        cli::cli_abort("self@files must be a list of non-empty character strings.")
      }
    }
    lapply(files, function(f) {
      assert_pattern_with_ext(f, ext = ".ttf")
    })

    file_names <- names(files)
    if (any(is.na(file_names)) || is.null(file_names) || any(file_names == "")) {
      cli::cli_abort("All elements of self@files must be named with weight or variant keys.")
    }

    if (self@key_scheme == "symbolic") {
      valid <- c("regular", "italic", "bold", "bolditalic")
      bad <- setdiff(file_names, valid)
      if (length(bad) > 0) {
        cli::cli_abort(c(
          "File names in {.arg self@files} must be weight keys or variant keys.",
          "x" = "Invalid key{?s}: {.val {bad}}"
        ))
      }
    } else {
      weight_rx <- "^(100|200|300|400|500|600|700|800|900)(?:italic)?$"
      bad <- file_names[!grepl(weight_rx, file_names)]
      if (length(bad) > 0) {
        cli::cli_abort(c(
          "File names in {.arg self@files} must be weight keys or variant keys.",
          "i" = "Weight keys: 100–900 with optional {.val italic} suffix (e.g. {.val 400}, {.val 700italic}).",
          "i" = "Variant keys: {.val regular}, {.val italic}, {.val bold}, {.val bolditalic}.",
          "x" = "Invalid key{?s}: {.val {bad}}"
        ))
      }
    }

    NULL
  }
)
