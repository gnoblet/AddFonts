test_that("CacheMeta S7 class basics works correctly", {
  meta <- CacheMeta(
    family_id = "fid",
    source = "bunny",
    files = list("400" = "r.ttf")
  )

  expect_s3_class(meta, "AddFonts::CacheMeta")
  expect_s7_class(meta, CacheMeta)

  expect_equal(meta@family_id, "fid")
  expect_equal(meta@source, "bunny")
  expect_equal(meta@files, list("400" = "r.ttf"))
  expect_true(is.character(meta@added))
})

test_that("CacheMeta validation works correctly", {
  # invalid family_id (empty)
  expect_error(
    CacheMeta(
      family_id = "",
      source = "bunny",
      files = list("400" = "r.ttf")
    ),
    "self@family_id must be a non-empty character string."
  )

  # invalid family_id (whitespace)
  expect_error(
    CacheMeta(
      family_id = "bad id!",
      source = "bunny",
      files = list("400" = "r.ttf")
    ),
    "self@family_id must not contain whitespace characters."
  )

  # invalid family_id (bad chars)
  expect_error(
    CacheMeta(
      family_id = "bad/id!",
      source = "bunny",
      files = list("400" = "r.ttf")
    ),
    "self@family_id contains invalid characters."
  )

  # invalid source (empty)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "",
      files = list("400" = "r.ttf")
    ),
    "self@source must be a non-empty character string."
  )

  # invalid files (not a list)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "bunny",
      files = "r.ttf"
    ),
    "@files must be <list>, not <character>"
  )

  # invalid files (empty list)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "bunny",
      files = list()
    ),
    "self@files must be a non-empty list."
  )

  # invalid files (not a list)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "bunny",
      files = NULL
    ),
    "@files must be <list>, not <NULL>"
  )

  # invalid list element (not character)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "bunny",
      files = list("400" = 42)
    ),
    "self@files must be a list of non-empty character strings."
  )

  # invalid files (bad path)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "bunny",
      files = list("400" = "r.woff2")
    ),
    "must be formatted as a path whose extension is '.ttf'."
  )

  # invalid file names (not weight pattern)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "bunny",
      files = list(regular = "r.ttf")
    ),
    "File names must follow the pattern '<weight>' or '<weight>italic'."
  )

  # invalid file names (unnamed)
  expect_error(
    CacheMeta(
      family_id = "fid",
      source = "bunny",
      files = list("r.ttf")
    ),
    "All elements of self@files must be named."
  )
})
