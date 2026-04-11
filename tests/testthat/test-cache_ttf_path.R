test_that("cache_ttf_path returns a path inside cache dir (mocked)", {
  tmp <- withr::local_tempdir()
  local_mocked_bindings(
    user_cache_dir = function(...) tmp,
    .package = "rappdirs"
  )
  p <- cache_ttf_path("src", "My Font", "latin", 400, "normal")
  expect_true(grepl("src-my-font-latin-400-normal\\.ttf$", p))
  # dirname() returns an fs_path; coerce both sides to character for comparison
  expect_equal(as.character(dirname(p)), as.character(tmp))
})

test_that("cache_ttf_filename composes expected filename", {
  filename <- cache_ttf_filename("src", "My Font", "latin", 400, "normal")
  expect_true(grepl("^src-my-font-latin-400-normal\\.ttf$", filename))
})

test_that("cache_ttf_path and cache_ttf_filename reject invalid weights", {

  # non-numeric weight
  expect_error(cache_ttf_path("src", "fam", "latin", "heavy", "normal"), "must be a single integer")
  expect_error(cache_ttf_filename("src", "fam", "latin", "heavy", "normal"), "must be a single integer")

  # weight out of range
  expect_error(cache_ttf_path("src", "fam", "latin", 50, "normal"), "must be a single integer")
  expect_error(cache_ttf_filename("src", "fam", "latin", 50, "normal"), "must be a single integer")

  # weight as vector (length > 1)
  expect_error(cache_ttf_path("src", "fam", "latin", c(400, 700), "normal"), "must be a single integer")
  expect_error(cache_ttf_filename("src", "fam", "latin", c(400, 700), "normal"), "must be a single integer")
})
