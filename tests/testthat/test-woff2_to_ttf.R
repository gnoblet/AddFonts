test_that("woff2_to_ttf errors for missing or wrong extension files", {
  expect_error(woff2_to_ttf("nonexistent.woff2"), "Font file not found")
  tmp <- fs::file_temp(ext = "woff")
  writeLines("x", tmp)
  expect_error(woff2_to_ttf(tmp), "Expected a .woff2 file")
  if (fs::file_exists(tmp)) fs::file_delete(tmp)
})
