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

test_that("font_search returns correct structure", {
  result <- font_search("roboto")

  expect_s3_class(result, "data.frame")
  expect_true(all(c("familyName", "category", "weights") %in% names(result)))
  expect_type(result$familyName, "character")
  expect_type(result$category, "character")
  expect_type(result$weights, "character")
})

test_that("font_search with invalid provider fails", {
  expect_error(
    font_search("roboto", provider = "nonexistent"),
    regexp = "not supported"
  )
})

test_that("font_search validates provider parameter", {
  expect_error(
    font_search("roboto", provider = ""),
    regexp = "not supported"
  )
})

test_that("font_search default provider is bunny", {
  result1 <- font_search("roboto")
  result2 <- font_search("roboto", provider = "bunny")

  expect_equal(result1, result2)
})

test_that("font_search with category and query works", {
  result <- font_search(query = "mono", category = "monospace")

  expect_s3_class(result, "data.frame")
  expect_true(all(result$category == "monospace"))
  # Should have matching fonts
  expect_true(nrow(result) > 0)
})

test_that("font_search with only category works", {
  result <- font_search(category = "serif")

  expect_s3_class(result, "data.frame")
  expect_true(all(result$category == "serif"))
  expect_true(nrow(result) > 0)
})

test_that("font_search with NULL query and category returns all fonts", {
  result <- font_search(query = NULL, category = NULL)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) == nrow(font_list()))
})

test_that("font_search is case-insensitive for provider", {
  result1 <- font_search("roboto", provider = "bunny")
  result2 <- font_search("roboto", provider = "BUNNY")
  result3 <- font_search("roboto", provider = "BuNnY")

  expect_equal(result1, result2)
  expect_equal(result2, result3)
})

test_that("font_search filters correctly by category case-insensitive", {
  result1 <- font_search(category = "sans-serif")
  result2 <- font_search(category = "SANS-SERIF")
  result3 <- font_search(category = "Sans-Serif")

  expect_equal(nrow(result1), nrow(result2))
  expect_equal(nrow(result2), nrow(result3))
  expect_true(all(tolower(result1$category) == "sans-serif"))
})
