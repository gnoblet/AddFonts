test_that("FontProvider constructs with valid inputs", {
  fp <- FontProvider(
    source = "bunny",
    url_template = "https://fonts.bunny.net/%s/files/%s-%s-%d-%s.woff2",
    conversion = "woff2_to_ttf",
    conversion_ext = "woff2",
    aliases = list("fonts.bunny.net")
  )

  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source, "bunny")
  expect_equal(
    fp@url_template,
    "https://fonts.bunny.net/%s/files/%s-%s-%d-%s.woff2"
  )
  expect_equal(fp@conversion, "woff2_to_ttf")
  expect_equal(fp@conversion_ext, "woff2")
  expect_equal(fp@aliases, list("fonts.bunny.net"))
})

test_that("FontProvider constructs with NULL conversion fields", {
  fp <- FontProvider(
    source = "google",
    url_template = "https://fonts.google.com/{family}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source, "google")
  expect_null(fp@conversion)
  expect_null(fp@conversion_ext)
})

test_that("FontProvider validator rejects empty source", {
  expect_error(
    FontProvider(
      source = "",
      url_template = "https://example.com/{family}.ttf",
      conversion = NULL,
      conversion_ext = NULL,
      aliases = list()
    ),
    "empty"
  )
})

test_that("FontProvider validator rejects empty url_template", {
  expect_error(
    FontProvider(
      source = "test",
      url_template = "",
      conversion = NULL,
      conversion_ext = NULL,
      aliases = list()
    ),
    "empty"
  )
})

test_that("FontProvider validator rejects invalid conversion type", {
  expect_error(
    FontProvider(
      source = "test",
      url_template = "https://example.com/{family}.ttf",
      conversion = c("func1", "func2"),
      conversion_ext = "woff2",
      aliases = list()
    ),
    "must be NULL or a non-empty character string"
  )
})

test_that("FontProvider validator rejects invalid conversion_ext type", {
  expect_error(
    FontProvider(
      source = "test",
      url_template = "https://example.com/{family}.ttf",
      conversion = "convert_func",
      conversion_ext = c("ext1", "ext2"),
      aliases = list()
    ),
    "must be NULL or a non-empty character string"
  )
})
