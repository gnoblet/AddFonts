test_that("assert_null_or_non_empty_string behaves correctly", {
  expect_silent(assert_null_or_non_empty_string(NULL))
  expect_silent(assert_null_or_non_empty_string("x"))
  expect_error(
    assert_null_or_non_empty_string(NULL, allow_null = FALSE),
    "must be a non-empty character string; NULL is not allowed"
  )
  expect_error(assert_null_or_non_empty_string(1), "non-empty character string")
  expect_error(
    assert_null_or_non_empty_string(c("a", "b")),
    "non-empty character string"
  )
  expect_error(
    assert_null_or_non_empty_string(NA_character_),
    "non-empty character string"
  )
  expect_error(
    assert_null_or_non_empty_string(""),
    "non-empty character string"
  )
})

test_that("assert_list_with_elements validates lists and required elements", {
  expect_silent(assert_list_with_elements(list()))
  l <- list(a = 1, b = "x")
  expect_silent(assert_list_with_elements(l))
  expect_silent(assert_list_with_elements(l, required_elements = c("a")))
  expect_error(assert_list_with_elements(1), "must be a list")
  expect_error(
    assert_list_with_elements(l, required_elements = c("c")),
    "is missing required elements"
  )
  expect_error(
    assert_list_with_elements(l, required_elements = c("c", "d")),
    "is missing required elements"
  )
})

test_that("assert_null_or_non_empty_character_vector behaves correctly", {
  # NULL allowed by default
  expect_silent(assert_null_or_non_empty_character_vector(NULL))

  # NULL disallowed
  expect_error(assert_null_or_non_empty_character_vector(NULL, allow_null = FALSE), "NULL is not allowed")

  # Valid single string
  expect_silent(assert_null_or_non_empty_character_vector("hello"))

  # Valid multi-element vector
  expect_silent(assert_null_or_non_empty_character_vector(c("a", "b")))

  # Non-character
  expect_error(assert_null_or_non_empty_character_vector(1L), "non-empty character vector")

  # Empty character vector
  expect_error(assert_null_or_non_empty_character_vector(character(0)), "non-empty character vector")

  # Empty string element
  expect_error(assert_null_or_non_empty_character_vector(""), "non-empty character vector")
  expect_error(assert_null_or_non_empty_character_vector(c("a", "")), "non-empty character vector")

  # All-NA vector
  expect_error(assert_null_or_non_empty_character_vector(NA_character_), "non-empty character vector")
})

test_that("assert_list_of_1_length_character_strings behaves correctly", {
  # Not a list
  expect_error(assert_list_of_1_length_character_strings("not a list"), "must be a list")

  # Empty list allowed by default (allow_empty = TRUE)
  expect_silent(assert_list_of_1_length_character_strings(list()))

  # Valid list of single strings
  expect_silent(assert_list_of_1_length_character_strings(list("a", "b")))

  # Element is non-character
  expect_error(assert_list_of_1_length_character_strings(list("a", 42L)), "non-empty character string")

  # Element is empty string
  expect_error(assert_list_of_1_length_character_strings(list("a", "")), "non-empty character string")

  # Element is NA
  expect_error(assert_list_of_1_length_character_strings(list("a", NA_character_)), "non-empty character string")

  # Element is length-2 character vector (not a scalar)
  expect_error(assert_list_of_1_length_character_strings(list(c("a", "b"))), "non-empty character string")
})

test_that("assert_pattern_with_ext validates paths and extensions", {
  # Valid path with extension
  expect_silent(assert_pattern_with_ext("fonts/roboto.ttf", ext = ".ttf"))

  # Valid path without extension requirement
  expect_silent(assert_pattern_with_ext("fonts/roboto-regular"))

  # Whitespace is never allowed
  expect_error(assert_pattern_with_ext("bad file.ttf", ext = ".ttf"), "whitespace")

  # Extension mismatch
  expect_error(assert_pattern_with_ext("roboto.woff2", ext = ".ttf"), "extension is '.ttf'")

  # All allow_* FALSE triggers "At least one" error
  expect_error(
    assert_pattern_with_ext(
      "a",
      allow_lowercase = FALSE, allow_uppercase = FALSE,
      allow_digits = FALSE, allow_dot = FALSE, allow_underscore = FALSE,
      allow_hyphen = FALSE, allow_forward_slash = FALSE,
      allow_backslash = FALSE, allow_colon = FALSE, allow_tilde = FALSE
    ),
    "At least one"
  )

  # Invalid character given flag restriction
  expect_error(
    assert_pattern_with_ext("a/b.ttf", ext = ".ttf", allow_forward_slash = FALSE),
    "contains invalid characters"
  )

  # Non-logical flag
  expect_error(assert_pattern_with_ext("file.ttf", allow_lowercase = "yes"), "single logical")
})

test_that("assert_string_in_set enforces non-empty string and choices", {
  expect_silent(assert_string_in_set("a", choices = c("a", "b")))
  expect_error(
    assert_string_in_set(NULL, choices = c("a")),
    "non-empty character string"
  )
  expect_error(
    assert_string_in_set("z", choices = c("a", "b")),
    "must be one of"
  )
})
