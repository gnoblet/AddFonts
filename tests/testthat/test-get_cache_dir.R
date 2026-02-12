test_that("get_cache_dir creates and returns a directory (mocked)", {
  tmp <- fs::file_temp()
  with_mocked_bindings(
    user_cache_dir = function(...) tmp,
    .package = "rappdirs",
    {
      if (fs::dir_exists(tmp)) {
        fs::dir_delete(tmp)
      }
      d <- get_cache_dir()
      expect_true(fs::dir_exists(d))
    }
  )
  if (fs::dir_exists(tmp)) fs::dir_delete(tmp)
})


test_that("get_cache_dir creates a directory with AddFonts in path", {
  d <- get_cache_dir()
  # On Windows, rappdirs adds /Cache suffix, so check for AddFonts anywhere in path
  expect_true(grepl("AddFonts", d))
})
