test_that("as_FontProvider constructs FontProvider from named list", {
  x <- list(
    source = "google",
    url_template = "https://fonts.example/{family}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list("gfonts")
  )

  fp <- as_FontProvider(x)

  expect_equal(fp@source, x$source)
  expect_equal(fp@url_template, x$url_template)
  expect_null(fp@conversion)
  expect_null(fp@conversion_ext)
  expect_equal(fp@aliases, x$aliases)

  # with non null conversion
  x2 <- list(
    source = "custom",
    url_template = "https://customfonts.example/{family}.zip",
    conversion = "unzip_font",
    conversion_ext = "zip",
    aliases = list()
  )
  fp2 <- as_FontProvider(x2)
})

test_that("as_FontProvider errors on missing required fields", {
  x_missing_source <- list(url_template = "https://example/{family}.ttf")
  x_missing_url <- list(source = "local")

  expect_error(as_FontProvider(x_missing_source))
  expect_error(as_FontProvider(x_missing_url))

  # tbh a bit unsure what to add more since it's basically mapped to FontProvider and will be validated there
})
