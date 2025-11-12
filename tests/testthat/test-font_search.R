test_that("font_search_bunny returns matching fonts", {
  result <- font_search_bunny("roboto")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(grepl("roboto", result$familyName, ignore.case = TRUE)))
})

test_that("font_search_bunny handles no matches", {
  expect_message(
    result <- font_search_bunny("DefinitelyNotARealFont123"),
    "No fonts found"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("font_search_bunny filters by category", {
  result <- font_search_bunny(category = "monospace")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(result$category == "monospace"))
})

test_that("font_search_bunny returns all fonts when query is NULL", {
  result <- font_search_bunny()

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 1000) # Should return all fonts
})

test_that("font_search with provider='bunny' works", {
  result <- font_search(query = "lato", provider = "bunny")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("font_search output includes weights column", {
  result <- font_search_bunny("roboto")

  expect_true("weights" %in% names(result))
  expect_type(result$weights, "character")

  # Weights should be formatted as comma-separated strings
  expect_true(all(grepl("\\d+", result$weights)))
})

test_that("font_search is case-insensitive", {
  result1 <- font_search_bunny("ROBOTO")
  result2 <- font_search_bunny("roboto")
  result3 <- font_search_bunny("RoBoTo")

  expect_equal(nrow(result1), nrow(result2))
  expect_equal(nrow(result2), nrow(result3))
})

test_that("font_search handles empty string query", {
  result <- font_search_bunny("")

  # Empty string should return all fonts
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 1000)
})

test_that("font_search validates category parameter", {
  # Valid category should work
  expect_no_error(font_search_bunny(category = "serif"))

  # Invalid category should still work but return empty result
  result <- font_search_bunny(category = "nonexistent_category")
  expect_equal(nrow(result), 0)
})

test_that("font_search S3 dispatch works correctly", {
  # Create object with class for dispatch
  obj <- structure(
    list(provider = "bunny", query = "roboto", category = NULL),
    class = "font_provider_bunny"
  )

  result <- font_search_dispatch(obj)
  expect_s3_class(result, "data.frame")
})
