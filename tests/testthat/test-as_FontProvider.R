## ---- Weight-type provider (default) ----

test_that("as_FontProvider constructs FontProviderWeight from list without type field", {
  x <- list(
    source = "google",
    url_template = "https://fonts.example/{family}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list("gfonts")
  )
  fp <- as_FontProvider(x)

  expect_s7_class(fp, FontProviderWeight)
  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source, "google")
  expect_equal(fp@url_template, "https://fonts.example/{family}.ttf")
  expect_null(fp@conversion)
  expect_null(fp@conversion_ext)
  expect_equal(fp@aliases, list("gfonts"))
})

test_that("as_FontProvider constructs FontProviderWeight from list with type = 'weight'", {
  x <- list(
    type = "weight",
    source = "custom",
    url_template = "https://customfonts.example/{family}.zip",
    conversion = "woff2_to_ttf",
    conversion_ext = "woff2",
    aliases = list()
  )
  fp <- as_FontProvider(x)

  expect_s7_class(fp, FontProviderWeight)
  expect_equal(fp@source, "custom")
  expect_equal(fp@conversion, "woff2_to_ttf")
  expect_equal(fp@conversion_ext, "woff2")
  expect_equal(fp@aliases, list())
})

test_that("as_FontProvider passes first_use_message and first_use_url for weight type", {
  x <- list(
    source = "x",
    url_template = "https://example.com/{family}.ttf",
    first_use_message = "Licence notice.",
    first_use_url     = "https://example.com/licence"
  )
  fp <- as_FontProvider(x)

  expect_s7_class(fp, FontProviderWeight)
  expect_equal(fp@first_use_message, "Licence notice.")
  expect_equal(fp@first_use_url,     "https://example.com/licence")
})

## ---- File-type provider ----

test_that("as_FontProvider constructs FontProviderFile from list with type = 'file'", {
  x <- list(
    type     = "file",
    source   = "bbb",
    base_url = "https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf"
  )
  fp <- as_FontProvider(x)

  expect_s7_class(fp, FontProviderFile)
  expect_s7_class(fp, FontProvider)
  expect_equal(fp@source,   "bbb")
  expect_equal(fp@base_url, "https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf")
  expect_equal(fp@file_ext, "ttf")   # default
})

test_that("as_FontProvider passes file_ext for file type", {
  x <- list(
    type     = "file",
    source   = "x",
    base_url = "https://example.com/{family}/{filename}.otf",
    file_ext = "otf"
  )
  fp <- as_FontProvider(x)

  expect_s7_class(fp, FontProviderFile)
  expect_equal(fp@file_ext, "otf")
})

test_that("as_FontProvider passes aliases and first_use fields for file type", {
  x <- list(
    type              = "file",
    source            = "bbb",
    base_url          = "https://example.com/{family}/{filename}.ttf",
    aliases           = list("example.com"),
    first_use_message = "Please respect the licence.",
    first_use_url     = "https://example.com/licence"
  )
  fp <- as_FontProvider(x)

  expect_equal(fp@aliases,           list("example.com"))
  expect_equal(fp@first_use_message, "Please respect the licence.")
  expect_equal(fp@first_use_url,     "https://example.com/licence")
})

## ---- Unknown type ----

test_that("as_FontProvider errors on unknown type", {
  expect_error(
    as_FontProvider(list(
      type   = "streaming",
      source = "x",
      base_url = "https://example.com/{family}/{filename}.ttf"
    )),
    "Unknown"
  )
})

## ---- Missing required fields ----

test_that("as_FontProvider errors when source is missing (weight type)", {
  expect_error(
    as_FontProvider(list(url_template = "https://example.com/{family}.ttf")),
    "properties are invalid"
  )
})

test_that("as_FontProvider errors when url_template is missing (weight type)", {
  expect_error(
    as_FontProvider(list(source = "local")),
    "properties are invalid"
  )
})

test_that("as_FontProvider errors when base_url is missing (file type)", {
  expect_error(
    as_FontProvider(list(type = "file", source = "bbb")),
    "properties are invalid"
  )
})
