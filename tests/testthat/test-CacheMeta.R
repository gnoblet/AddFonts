test_that("CacheMeta S7 class basics works correctly", {
  meta <- CacheMeta(
    source = "bunny",
    files = list("400" = "r.ttf")
  )

  expect_s3_class(meta, "AddFonts::CacheMeta")
  expect_s7_class(meta, CacheMeta)

  expect_equal(meta@source, "bunny")
  expect_equal(meta@files, list("400" = "r.ttf"))
})

test_that("CacheMeta validation works correctly", {
  # invalid source (empty)
  expect_error(
    CacheMeta(
      source = "",
      files = list("400" = "r.ttf")
    ),
    "self@source must be a non-empty character string."
  )

  # invalid files (not a list)
  expect_error(
    CacheMeta(
      source = "bunny",
      files = "r.ttf"
    ),
    "@files must be <list>, not <character>"
  )

  # invalid files (empty list)
  expect_error(
    CacheMeta(
      source = "bunny",
      files = list()
    ),
    "self@files must be a non-empty list."
  )

  # invalid files (not a list)
  expect_error(
    CacheMeta(
      source = "bunny",
      files = NULL
    ),
    "@files must be <list>, not <NULL>"
  )

  # invalid list element (not character)
  expect_error(
    CacheMeta(
      source = "bunny",
      files = list("400" = 42)
    ),
    "self@files must be a list of non-empty character strings."
  )

  # invalid files (bad path)
  expect_error(
    CacheMeta(
      source = "bunny",
      files = list("400" = "r.woff2")
    ),
    "must be formatted as a path whose extension is '.ttf'."
  )

  # symbolic variant keys are valid (file-based providers)
  expect_no_error(
    CacheMeta(
      source = "bbb",
      files = list(regular = "r.ttf", bold = "b.ttf")
    )
  )

  # invalid file names (unknown key — neither weight nor symbolic)
  expect_error(
    CacheMeta(
      source = "bunny",
      files = list(foo = "r.ttf")
    ),
    "must be weight keys or variant keys"
  )

  # invalid file names (unnamed)
  expect_error(
    CacheMeta(
      source = "bunny",
      files = list("r.ttf")
    ),
    "All elements of self@files must be named."
  )
})
