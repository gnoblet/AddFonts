test_that("get_cache_dir creates and returns a directory (mocked)", {
  parent <- withr::local_tempdir()
  tmp <- fs::path(parent, "cache_dir_test")
  local_mocked_bindings(
    user_cache_dir = function(...) tmp,
    .package = "rappdirs"
  )
  d <- get_cache_dir()
  expect_true(fs::dir_exists(d))
})


test_that("get_cache_dir creates a directory with AddFonts in path", {
  parent <- withr::local_tempdir()
  mock_path <- fs::path(parent, "AddFonts")
  local_mocked_bindings(
    user_cache_dir = function(...) mock_path,
    .package = "rappdirs"
  )
  d <- get_cache_dir()
  expect_true(grepl("AddFonts", d))
})
