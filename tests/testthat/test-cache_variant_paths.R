test_that("cache_variant_paths validates provider and returns expected paths", {
  tmp <- fs::file_temp()
  dir.create(tmp)
  on.exit(if (fs::dir_exists(tmp)) fs::dir_delete(tmp))

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
    "must be a <FontProvider> object"
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
