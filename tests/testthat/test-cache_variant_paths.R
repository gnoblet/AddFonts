test_that("cache_ttf_filename produces correct filename format", {
  fname <- cache_ttf_filename("bunny", "Roboto", "latin", 400, "normal")
  expect_equal(fname, "bunny-roboto-latin-400-normal.ttf")
})

test_that("cache_ttf_filename applies safe_id to font_id", {
  fname <- cache_ttf_filename("bunny", "My Font", "latin", 700, "italic")
  expect_equal(fname, "bunny-my-font-latin-700-italic.ttf")
})

test_that("cache_ttf_filename rejects invalid weight", {
  expect_error(
    cache_ttf_filename("bunny", "roboto", "latin", 999, "normal"),
    "between 100 and 900"
  )
})

test_that("cache_file_path produces correctly formatted path", {
  tmp <- withr::local_tempdir()
  path <- cache_file_path("bbb", "My Font", "regular", "ttf", cache_dir = tmp)
  expect_true(grepl("bbb-my-font-regular\\.ttf$", as.character(path)))
  expect_true(startsWith(as.character(path), tmp))
})

test_that("cache_file_path respects file_ext and variant", {
  tmp <- withr::local_tempdir()
  path <- cache_file_path("bbb", "roboto", "bold", "otf", cache_dir = tmp)
  expect_true(grepl("bbb-roboto-bold\\.otf$", as.character(path)))
})

test_that("cache_variant_paths validates provider and returns expected paths", {
  tmp <- withr::local_tempdir()

  # invalid provider object (not FontProvider)
  expect_error(
    cache_variant_paths(
      "nope",
      "fam",
      400,
      "normal",
      "latin",
      cache_dir = tmp
    ),
    "must be a"
  )

  # happy path without conversion
  provider_no_conv <- new_test_provider(
    source = "src",
    conversion = NULL,
    conversion_ext = NULL
  )
  paths <- cache_variant_paths(
    provider_no_conv,
    "My Font",
    400,
    "normal",
    "latin",
    cache_dir = tmp
  )
  expect_true(is.list(paths))
  expect_null(paths$to_convert)
  expect_true(grepl(
    "src-my-font-latin-400-normal\\.ttf$",
    as.character(paths$ttf)
  ))

  # happy path with conversion specified
  provider_with_conv <- new_test_provider(
    source = "src",
    conversion = "woff2_to_ttf",
    conversion_ext = "woff2"
  )
  paths2 <- cache_variant_paths(
    provider_with_conv,
    "My Font",
    700,
    "italic",
    "latin",
    cache_dir = tmp
  )
  expect_true(is.list(paths2))
  expect_true(grepl(
    "src-my-font-latin-700-italic\\.woff2$",
    as.character(paths2$to_convert)
  ))
  expect_true(grepl(
    "src-my-font-latin-700-italic\\.ttf$",
    as.character(paths2$ttf)
  ))
})
