test_that("font_list_bunny returns a data.frame", {
  result <- font_list_bunny()

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("familyName" %in% names(result))
  expect_true("category" %in% names(result))
})

test_that("font_list_bunny returns expected structure", {
  result <- font_list_bunny()

  # Check key columns exist
  expected_cols <- c(
    "family",
    "familyName",
    "category",
    "variants",
    "weights",
    "styles",
    "defSubset"
  )
  expect_true(all(expected_cols %in% names(result)))

  # Check data types
  expect_type(result$family, "character")
  expect_type(result$familyName, "character")
  expect_type(result$category, "character")
})

test_that("font_list with provider='bunny' works", {
  result <- font_list(provider = "bunny")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("font_list with invalid provider fails", {
  expect_error(
    font_list(provider = "nonexistent"),
    regexp = "provider"
  )
})

test_that("fonts_bunny data is available", {
  # This test verifies the lazy-loaded data
  expect_true(exists("fonts_bunny"))
  expect_s3_class(fonts_bunny, "data.frame")
  expect_true(nrow(fonts_bunny) > 1000) # Should have many fonts
})

test_that("font_list returns correct categories", {
  result <- font_list_bunny()

  # Bunny Fonts has standard CSS categories
  categories <- unique(result$category)
  expected_categories <- c(
    "sans-serif",
    "serif",
    "display",
    "handwriting",
    "monospace"
  )

  expect_true(all(categories %in% expected_categories))
})
