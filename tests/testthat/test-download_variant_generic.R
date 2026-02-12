test_that("download_variant_generic validates weight and returns appropriate errors", {
  fn <- getFromNamespace("download_variant_generic", "AddFonts")
  provider <- new_bunny_provider()
  expect_error(
    fn(provider, "fam", 50, "normal"),
    "must be a single integer"
  )
})
