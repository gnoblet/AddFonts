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
