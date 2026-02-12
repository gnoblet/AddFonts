#' @include CacheMeta.R
NULL

#' S7-backed cache entry (CacheEntry)
#'
#' @typed family: character(1)
#'  Family name for this cache entry (safe identifier containing only letters, digits, and hyphens).
#'
#' @typed meta: CacheMeta
#'  A `CacheMeta` object describing the cached files and origin for this family.
#'
#' @typedreturn S7_object
#'  A validated S7 `CacheEntry` object.
#'
#' @export
CacheEntry <- S7::new_class(
  "CacheEntry",
  properties = list(
    family = S7::class_character,
    meta = CacheMeta
  ),
  validator = function(self) {
    # family is a non-empty string
    assert_null_or_non_empty_string(self@family, allow_null = FALSE)

    # assert family is only made of safe chars
    assert_pattern_with_ext(
      self@family,
      ext = NULL,
      allow_dot = FALSE,
      allow_underscore = FALSE,
      allow_forward_slash = FALSE,
      allow_backslash = FALSE,
      allow_colon = FALSE,
      allow_tilde = FALSE
    )

    # family is different from meta@family_id
    if (self@family != self@meta@family_id) {
      cli::cli_warn(
        "self@family is different from self@family_id."
      )
    }

    NULL
  }
)
