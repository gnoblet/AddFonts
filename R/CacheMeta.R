#' S7-backed cache metadata (CacheMeta)
#'
#' @typed family_id: character(1)
#'  A non-empty safe identifier for the font family. Allowed characters: letters,
#'  digits and hyphen (no spaces, slashes, dots, colons, tildes, etc.).
#'
#' @typed source: character(1)
#'  Name of the provider or source that produced the cached font files.
#'
#' @typed files: list(1+)
#'  A non-empty named list of file paths. Names are weight identifiers (e.g., "400" for normal weight 400,
#'  "400italic" for italic weight 400). Each element is a character(1) path to the local font files.
#'
#' @details
#' The `added` property is a getter-only field that returns the current timestamp as a character string when accessed. It cannot be set during construction.
#'
#' Weights are not explicitly stored - they are derived from the names of the files list.
#' Registration functions are responsible for selecting appropriate weights for regular/bold variants.
#'
#' @typedreturn S7_object
#'  A validated S7 `CacheMeta` object.
#'
#' @export
CacheMeta <- S7::new_class(
  "CacheMeta",
  properties = list(
    family_id = S7::class_character,
    source = S7::class_character,
    files = S7::class_list,
    added = S7::new_property(S7::class_character, getter = function(self) {
      as.character(Sys.time())
    })
  ),
  validator = function(self) {
    # familiy id is a safe_id (non-empty string with allowed chars)
    assert_null_or_non_empty_string(self@family_id, allow_null = FALSE)

    # family id has safe chars
    assert_pattern_with_ext(
      self@family_id,
      ext = NULL,
      allow_dot = FALSE,
      allow_uppercase = FALSE,
      allow_forward_slash = FALSE,
      allow_backslash = FALSE,
      allow_colon = FALSE,
      allow_tilde = FALSE
    )

    # source is a non-empty string
    assert_null_or_non_empty_string(self@source, allow_null = FALSE)

    files <- self@files
    # - non-empty list of non-empty character strings
    if (!is.list(files) || length(files) == 0) {
      cli::cli_abort(
        "self@files must be a non-empty list."
      )
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

    # Validate file names follow weight pattern (e.g., "400", "400italic", "700italic")
    file_names <- names(files)
    if (
      any(is.na(file_names)) || is.null(file_names) || any(file_names == "")
    ) {
      cli::cli_abort(
        "All elements of self@files must be named (with weight identifiers)."
      )
    }

    # Check that names match the pattern: valid weight (100-900) followed by optional "italic"
    valid_pattern <- grepl(
      "^(100|200|300|400|500|600|700|800|900)(?:italic)?$",
      file_names
    )
    if (!all(valid_pattern)) {
      invalid_names <- file_names[!valid_pattern]
      cli::cli_abort(
        paste0(
          "File names must follow the pattern '<weight>' or '<weight>italic', ",
          "where weight is 100, 200, 300, 400, 500, 600, 700, 800, or 900. ",
          "Invalid names: ",
          paste(invalid_names, collapse = ", ")
        )
      )
    }

    NULL
  }
)
