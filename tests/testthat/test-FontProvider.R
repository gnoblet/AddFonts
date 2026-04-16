## ---- FontProviderWeight (weight-based provider) ----

test_that("FontProviderWeight constructs with valid inputs", {
  fp <- FontProviderWeight(
    source = "bunny",
    url_template = "https://fonts.bunny.net/{family}/files/{family}-{subset}-{weight}-{style}.woff2",
    conversion = "woff2_to_ttf",
    conversion_ext = "woff2",
    aliases = list("fonts.bunny.net")
  )

  expect_s7_class(fp, FontProviderWeight)
  expect_s7_class(fp, FontProvider)   # inherits base
  expect_equal(fp@source, "bunny")
  expect_equal(
    fp@url_template,
    "https://fonts.bunny.net/{family}/files/{family}-{subset}-{weight}-{style}.woff2"
  )
  expect_equal(fp@conversion, "woff2_to_ttf")
  expect_equal(fp@conversion_ext, "woff2")
  expect_equal(fp@aliases, list("fonts.bunny.net"))
})

test_that("FontProviderWeight inherits first_use_message and first_use_url", {
  fp <- FontProviderWeight(
    source = "x",
    url_template = "https://example.com/{family}.ttf",
    first_use_message = "Hello!",
    first_use_url = "https://example.com/"
  )
  expect_equal(fp@first_use_message, "Hello!")
  expect_equal(fp@first_use_url, "https://example.com/")
})

test_that("FontProviderWeight validator rejects url_template without {family}", {
  expect_error(
    FontProviderWeight(
      source = "test",
      url_template = "https://example.com/%s/%s.woff2"
    ),
    "\\{family\\}"
  )
})

test_that("FontProviderWeight constructs with NULL conversion fields", {
  fp <- FontProviderWeight(
    source = "google",
    url_template = "https://fonts.google.com/{family}.ttf",
    conversion = NULL,
    conversion_ext = NULL,
    aliases = list()
  )

  expect_s7_class(fp, FontProviderWeight)
  expect_null(fp@conversion)
  expect_null(fp@conversion_ext)
})

test_that("FontProviderWeight validator rejects empty source", {
  expect_error(
    FontProviderWeight(
      source = "",
      url_template = "https://example.com/{family}.ttf"
    ),
    "empty"
  )
})

test_that("FontProviderWeight validator rejects empty url_template", {
  expect_error(
    FontProviderWeight(
      source = "test",
      url_template = ""
    ),
    "empty"
  )
})

test_that("FontProviderWeight validator rejects vector conversion", {
  expect_error(
    FontProviderWeight(
      source = "test",
      url_template = "https://example.com/{family}.ttf",
      conversion = c("func1", "func2")
    ),
    "must be NULL or a non-empty character string"
  )
})

test_that("FontProviderWeight validator rejects vector conversion_ext", {
  expect_error(
    FontProviderWeight(
      source = "test",
      url_template = "https://example.com/{family}.ttf",
      conversion_ext = c("ext1", "ext2")
    ),
    "must be NULL or a non-empty character string"
  )
})

## ---- FontProviderFile (file-based provider) ----

test_that("FontProviderFile constructs with valid inputs", {
  fp <- FontProviderFile(
    source   = "bbb",
    base_url = "https://gitlab.com/bye-bye-binary/{family}/-/raw/main/ttf/{filename}.ttf"
  )

  expect_s7_class(fp, FontProviderFile)
  expect_s7_class(fp, FontProvider)   # inherits base
  expect_equal(fp@source, "bbb")
  expect_equal(fp@file_ext, "ttf")    # default
  expect_null(fp@first_use_message)
})

test_that("FontProviderFile accepts first_use_message and first_use_url", {
  fp <- FontProviderFile(
    source            = "bbb",
    base_url          = "https://example.com/{family}/{filename}.ttf",
    first_use_message = "Please read the licence.",
    first_use_url     = "https://example.com/licence"
  )
  expect_equal(fp@first_use_message, "Please read the licence.")
  expect_equal(fp@first_use_url, "https://example.com/licence")
})

test_that("FontProviderFile validator rejects base_url missing {family}", {
  expect_error(
    FontProviderFile(
      source   = "bbb",
      base_url = "https://example.com/{filename}.ttf"
    ),
    "\\{family\\}"
  )
})

test_that("FontProviderFile validator rejects base_url missing {filename}", {
  expect_error(
    FontProviderFile(
      source   = "bbb",
      base_url = "https://example.com/{family}/file.ttf"
    ),
    "\\{filename\\}"
  )
})

test_that("FontProviderFile accepts custom file_ext", {
  fp <- FontProviderFile(
    source   = "x",
    base_url = "https://example.com/{family}/{filename}.otf",
    file_ext = "otf"
  )
  expect_equal(fp@file_ext, "otf")
})

## ---- Base FontProvider guard ----

test_that("bare FontProvider() construction is rejected", {
  expect_error(FontProvider(), "FontProviderWeight|FontProviderFile")
})
