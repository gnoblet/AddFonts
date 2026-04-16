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

## ---- cache_file_path (symbolic variant keys) ----

test_that("cache_file_path constructs expected path for symbolic variant", {
  tmp <- withr::local_tempdir()
  path <- cache_file_path(
    source    = "bbb",
    family    = "Alpaga",
    variant   = "regular",
    file_ext  = "ttf",
    cache_dir = tmp
  )
  expect_equal(basename(path), "bbb-alpaga-regular.ttf")
  expect_equal(as.character(dirname(path)), as.character(tmp))
})

test_that("cache_file_path makes family name filesystem-safe", {
  tmp <- withr::local_tempdir()
  path <- cache_file_path(
    source    = "bbb",
    family    = "My Font",
    variant   = "bold",
    file_ext  = "ttf",
    cache_dir = tmp
  )
  expect_equal(basename(path), "bbb-my-font-bold.ttf")
})

test_that("cache_file_path respects file_ext", {
  tmp <- withr::local_tempdir()
  path <- cache_file_path(
    source    = "x",
    family    = "font",
    variant   = "italic",
    file_ext  = "otf",
    cache_dir = tmp
  )
  expect_match(basename(path), "\\.otf$")
})

test_that("cache_file_path errors on empty source", {
  tmp <- withr::local_tempdir()
  expect_error(
    cache_file_path("", "family", "regular", "ttf", tmp),
    "empty"
  )
})

test_that("cache_file_path uses get_cache_dir when cache_dir is NULL", {
  tmp <- withr::local_tempdir()
  local_mocked_bindings(
    user_cache_dir = function(...) tmp,
    .package = "rappdirs"
  )
  path <- cache_file_path("bbb", "alpaga", "regular", "ttf")
  expect_match(path, "bbb-alpaga-regular\\.ttf$")
})
