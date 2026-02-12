test_that("cache_ttf_path returns a path inside cache dir (mocked)", {
  tmp <- fs::file_temp()
  dir.create(tmp)
  with_mocked_bindings(
    user_cache_dir = function(...) tmp,
    .package = "rappdirs",
    {
      p <- cache_ttf_path("src", "My Font", "latin", 400, "normal")
      expect_true(grepl("src-my-font-latin-400-normal\\.ttf$", p))
      # dirname() returns an fs_path; coerce both sides to character for comparison
      expect_equal(as.character(dirname(p)), as.character(tmp))
    }
  )
  if (fs::dir_exists(tmp)) fs::dir_delete(tmp)
})

test_that("cache_ttf_filename composes expected filename", {
  fn <- cache_ttf_filename("src", "My Font", "latin", 400, "normal")
  expect_true(grepl("^src-my-font-latin-400-normal\\.ttf$", fn))
})
