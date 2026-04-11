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

    # The safe-id of family must match meta@family_id to keep cache consistent.
    # (family may differ in case or special chars from family_id, which is fine)
    if (safe_id(self@family) != self@meta@family_id) {
      cli::cli_abort(c(
        "{.arg family} and {.arg meta@family_id} refer to different fonts.",
        "x" = "{.fn safe_id}({.val {self@family}}) = {.val {safe_id(self@family)}}, but meta@family_id = {.val {self@meta@family_id}}"
      ))
    }

    NULL
  }
)
