test_that("as_FontProvider constructs FontProvider from named list with null conversion", {
  x <- list(
    source = "google",
    url_template = "https://fonts.example/{family}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list("gfonts")
  )
  fp <- as_FontProvider(x)

  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source, x$source)
  expect_equal(fp@url_template, x$url_template)
  expect_null(fp@conversion)
  expect_null(fp@conversion_ext)
  expect_equal(fp@aliases, x$aliases)
})

test_that("as_FontProvider constructs FontProvider with non-null conversion", {
  x <- list(
    source = "custom",
    url_template = "https://customfonts.example/{family}.zip",
    conversion = "unzip_font",
    conversion_ext = "zip",
    aliases = list()
  )
  fp <- as_FontProvider(x)

  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source, "custom")
  expect_equal(fp@conversion, "unzip_font")
  expect_equal(fp@conversion_ext, "zip")
  expect_equal(fp@aliases, list())
})

test_that("as_FontProvider errors on missing required fields", {
  expect_error(
    as_FontProvider(list(url_template = "https://example/{family}.ttf")),
    "properties are invalid"
  )
  expect_error(
    as_FontProvider(list(source = "local")),
    "properties are invalid"
  )
})
