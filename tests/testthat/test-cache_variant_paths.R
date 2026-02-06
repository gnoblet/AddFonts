test_that("cache_variant_paths validates provider and returns expected paths", {
  tmp <- fs::file_temp()
  dir.create(tmp)
  on.exit(if (fs::dir_exists(tmp)) fs::dir_delete(tmp))

  # invalid provider object
  expect_error(cache_variant_paths(
    "nope",
    "fam",
    400,
    "normal",
    "latin",
    cache_dir = tmp
  ))

  # provider missing source
  expect_error(cache_variant_paths(
    list(conversion = NULL, conversion_ext = NULL),
    "fam",
    400,
    "normal",
    "latin",
    cache_dir = tmp
  ))

  # provider missing conversion keys
  expect_error(cache_variant_paths(
    list(source = "src"),
    "fam",
    400,
    "normal",
    "latin",
    cache_dir = tmp
  ))

  # happy path without conversion
  pl <- list(source = "src", conversion = NULL, conversion_ext = NULL)
  paths <- cache_variant_paths(
    pl,
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
  pl2 <- list(
    source = "src",
    conversion = "woff2_to_ttf",
    conversion_ext = "woff2"
  )
  paths2 <- cache_variant_paths(
    pl2,
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
