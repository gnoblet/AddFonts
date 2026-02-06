test_that("cache_ttf_filename composes expected filename", {
  fn <- cache_ttf_filename("src", "My Font", "latin", 400, "normal")
  expect_true(grepl("^src-my-font-latin-400-normal\\.ttf$", fn))
})
