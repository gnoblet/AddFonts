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
#'  A non-empty named list of file paths. Each element is a character(1) path to the local font files.
#'
#' @typed added: getter-only character(1)
#'  Timestamp when the meta was added using `Sys.time()`.
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

    NULL
  }
)
