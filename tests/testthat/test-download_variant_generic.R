test_that("download_variant_generic validates weight and returns appropriate errors", {
  fn <- getFromNamespace("download_variant_generic", "AddFonts")
  expect_error(
    fn(new_bunny_provider(), "fam", 50, "normal"),
    "must be a single integer"
  )
})
